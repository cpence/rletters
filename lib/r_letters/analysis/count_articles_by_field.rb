# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    # Code for counting the number of articles in a dataset, grouped by a field
    class CountArticlesByField
      # Create a new object for counting articles in a datset by field
      #
      # Pass the dataset you'd like to count, or `nil` to indicate the entire
      # corpus.
      #
      # @param [Dataset] dataset the dataset to analyze (or nil)
      # @param [Proc] progress If set, a function to call with a percentage of
      #   completion (one Integer parameter)
      def initialize(dataset = nil, progress = nil)
        @dataset = dataset
        @progress = progress
      end

      # Count up a dataset (or the corpus) by a field
      #
      # This function takes a Solr field, groups the articles of interest by
      # the values for the given field, and returns the result in a hash.
      #
      # FIXME: This function should support the same kind of work with names
      # that we have in RLetters::Documents::Author.
      #
      # @param [Symbol] field field to group by
      # @return [Hash<String, Integer>] number of documents in each grouping
      # @example Group a dataset by year of publication
      #   RLetters::Analysis::CountArticlesByField.new(dataset).counts_for(:year)
      #   # => { '1940' => 3, '1941' => 5, ... }
      def counts_for(field)
        @dataset ? group_dataset(@dataset, field) : group_corpus(field)
      end

      private

      # Walk a dataset manually and group it by field
      #
      # @api private
      # @param [Dataset] dataset set to count
      # @param [Symbol] field field to group by
      # @return [Hash<String, Integer>] number of documents in each group
      def group_dataset(dataset, field)
        ret = {}
        total = dataset.entries.size

        enum = RLetters::Datasets::DocumentEnumerator.new(dataset)
        enum.each_with_index do |doc, i|
          key = get_field_for_grouping(doc, field)
          ret[key] ||= 0
          ret[key] += 1

          @progress.call((i.to_f / total.to_f * 100.0).to_i) if @progress
        end

        @progress.call(100) if @progress

        ret
      end

      # Group the entire corpus by field, using Solr's result grouping
      #
      # @api private
      # @param [Symbol] field field to group by
      # @return [Hash<String, Integer>] number of documents in each group
      def group_corpus(field)
        ret = {}
        start = 0

        num_docs = 0
        total_docs = RLetters::Solr::CorpusStats.new.size

        loop do
          search_result = RLetters::Solr::Connection.search_raw({
            q: '*:*',
            def_type: 'lucene',
            group: 'true',
            'group.field' => field.to_s,
            fl: 'uid',
            facet: 'false',
            start: start.to_s,
            rows: 100
          })

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
            if @progress
              num_docs += g['doclist']['numFound']
              @progress.call((num_docs.to_f / total_docs.to_f * 100.0).to_i)
            end
          end

          # Get the next batch of groups
          start = start + 100
        end

        @progress.call(100) if @progress

        ret
      end

      # Get the value of the field for grouping
      #
      # This implements support for strange year values.
      #
      # @api private
      # @param [Document] doc the Solr document
      # @param [Symbol] field the field for grouping
      # @return [String] the field value
      def get_field_for_grouping(doc, field)
        return doc.send(field) unless field == :year

        # Support Y-M-D or Y/M/D dates, even though this field is supposed to
        # be only year values
        parts = doc.year.split(/[-\/]/)
        parts[0]
      end
    end
  end
end
