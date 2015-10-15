
module RLetters
  module Analysis
    # Code for counting the number of articles in a dataset, grouped by a field
    #
    # @!attribute field
    #   @return [Symbol] the field to group by
    # @!attribute dataset
    #   @return [Dataset] if set, the dataset to analyze (else the entire
    #     corpus)
    # @!attribute progress
    #   @return [Proc] if set, a function to call with percentage of completion
    #     (one integer parameter)
    class CountArticlesByField
      include Service
      include Virtus.model(strict: true, required: false, nullify_blank: true)

      attribute :field, Symbol
      attribute :dataset, Dataset
      attribute :progress, Proc

      # Count up a dataset (or the corpus) by a field
      #
      # This function takes a Solr field, groups the articles of interest by
      # the values for the given field, and returns the result in a hash.
      #
      # @todo This function should support the same kind of work with names
      #   that we have in RLetters::Documents::Author.
      #
      # @return [Hash<String, Integer>] number of documents in each grouping
      def call
        dataset ? group_dataset : group_corpus
      end

      private

      # Walk a dataset manually and group it by field
      #
      # @return [Hash<String, Integer>] number of documents in each group
      def group_dataset
        ret = {}
        total = dataset.entries.size

        enum = RLetters::Datasets::DocumentEnumerator.new(dataset)
        enum.each_with_index do |doc, i|
          key = get_field_from_document(doc)
          ret[key] ||= 0
          ret[key] += 1

          progress && progress.call((i.to_f / total.to_f * 100.0).to_i)
        end

        progress && progress.call(100)

        ret
      end

      # Group the entire corpus by field, using Solr's result grouping
      #
      # @return [Hash<String, Integer>] number of documents in each group
      def group_corpus
        ret = {}
        start = 0

        num_docs = 0
        total_docs = RLetters::Solr::CorpusStats.new.size

        loop do
          search_result = RLetters::Solr::Connection.search_raw(
            q: '*:*',
            def_type: 'lucene',
            group: 'true',
            'group.field' => field.to_s,
            fl: 'uid',
            facet: 'false',
            start: start.to_s,
            rows: 100)

          # These conditions would indicate a malformed Solr response
          break unless search_result['grouped'] &&
                       search_result['grouped'][field.to_s] &&
                       search_result['grouped'][field.to_s]['matches']

          grouped = search_result['grouped'][field.to_s]
          break if grouped['matches'] == 0

          groups = grouped['groups']
          break unless groups

          # This indicates that we're out of records
          break if groups.empty?

          # Add this batch to the return
          groups.each do |g|
            key = g['groupValue']
            val = g['doclist']['numFound']

            ret[key] = val

            # Update the progress meter
            if progress
              num_docs += g['doclist']['numFound']
              progress.call((num_docs.to_f / total_docs.to_f * 100.0).to_i)
            end
          end

          # Get the next batch of groups
          start += 100
        end

        progress && progress.call(100)

        ret
      end

      # Get the value of the field for grouping from a document
      #
      # This implements support for strange year values.
      #
      # @param [Document] doc the Solr document
      # @return [String] the field value
      def get_field_from_document(doc)
        return doc.send(field) unless field == :year

        # Support Y-M-D or Y/M/D dates, even though this field is supposed to
        # be only year values
        parts = doc.year.split(%r{[-/]})
        parts[0]
      end
    end
  end
end
