
module RLetters
  module Analysis
    # Code for counting the occurrences of a term in a dataset, grouped
    #
    # @!attribute term
    #   @return [String] the term to search for
    # @!attribute field
    #   @return [Symbol] the field to group by
    # @!attribute dataset
    #   @return [Dataset] if set, the dataset to analyze (else the entire
    #     corpus)
    # @!attribute progress
    #   @return [Proc] if set, a function to call with percentage of completion
    #     (one integer parameter)
    class CountTermsByField
      include Service
      include Virtus.model(strict: true, required: false, nullify_blank: true)

      attribute :term, String, required: true
      attribute :field, Symbol
      attribute :dataset, Dataset
      attribute :progress, Proc

      # Count term occurrences, grouping by a field
      #
      # This function takes a term, searches through a dataset (or the corpus)
      # for all the occurrences of that term, takes the number of term
      # occurrences in the dataset, and groups those occurrences by another
      # field of interest (e.g., by year, by journal, etc.).  The result is
      # returned in a hash.
      #
      # @todo This function should support the same kind of work with names
      #   that we have in RLetters::Documents::Author.
      #
      # @return [Hash<String, Integer>] number of documents in each grouping
      def call
        uids = dataset ? grouped_uids_dataset : grouped_uids_corpus
        uids_to_term_counts(uids)
      end

      private

      # Group the UIDs in a dataset manually by field
      #
      # @return [Hash<String, Array<String>>] list of UIDs for each group
      def grouped_uids_dataset
        ret = {}
        total = dataset.entries.size

        enum = RLetters::Datasets::DocumentEnumerator.new(dataset)
        enum.each_with_index do |doc, i|
          key = get_field_from_document(doc)
          ret[key] ||= []
          ret[key] << doc.uid

          progress && progress.call((i.to_f / total.to_f * 50.0).to_i)
        end

        progress && progress.call(50)

        ret
      end

      # Group the UIDs in the entire corpus by field
      #
      # @return [Hash<String, Array<String>>] list of UIDs for each group
      def grouped_uids_corpus
        ret = {}
        start = 0

        num_docs = 0
        total_docs = RLetters::Solr::CorpusStats.new.size

        loop do
          group_result = RLetters::Solr::Connection.search_raw(
            q: "fulltext:\"#{term}\"",
            def_type: 'lucene',
            group: 'true',
            'group.field' => field.to_s,
            fl: 'uid',
            facet: 'false',
            start: start.to_s,
            rows: 1)

          # These conditions would indicate a malformed Solr response
          break unless group_result['grouped'] &&
                       group_result['grouped'][field.to_s] &&
                       group_result['grouped'][field.to_s]['matches']

          grouped = group_result['grouped'][field.to_s]
          break if grouped['matches'] == 0

          groups = grouped['groups']
          break unless groups

          # This indicates that we're out of records
          break if groups.empty?

          # Get the group
          group = groups[0]

          # Run a new query to get all of the UIDs
          key = group['groupValue']
          group_size = group['doclist']['numFound']

          uids_result = RLetters::Solr::Connection.search_raw(
            q: "fulltext:\"#{term}\"",
            def_type: 'lucene',
            group: 'true',
            'group.field' => field.to_s,
            fl: 'uid',
            facet: 'false',
            start: start.to_s,
            rows: 1,
            'group.limit' => group_size)

          # Malformed Solr response
          break unless uids_result['grouped'] &&
                       uids_result['grouped'][field.to_s] &&
                       uids_result['grouped'][field.to_s]['groups']

          # Turn the documents list into a UIDs list
          uid_group = uids_result['grouped'][field.to_s]['groups'][0]
          ret[key] = uid_group['doclist']['docs'].map do |doc|
            doc['uid']
          end

          # Get the next group
          start += 1

          # Update the progress meter
          if progress
            num_docs += group_size
            progress.call((num_docs.to_f / total_docs.to_f * 50.0).to_i)
          end
        end

        progress && progress.call(50)

        ret
      end

      # Get the value of the field for grouping
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

      # Convert a list of grouped UIDs to term counts
      #
      # Query all the documents listed, get their counts for the term of
      # interest, and return them as a new hash.
      #
      # @param [Hash<String, Array<String>>] uids the grouped UIDs to fetch
      # @return [Hash<String, Integer>] grouped term counts by field
      def uids_to_term_counts(uids)
        ret = {}
        total = uids.size

        uids.each_with_index do |(key, arr), i|
          ret[key] = 0

          arr.each do |uid|
            doc = Document.find(uid, term_vectors: true)
            vec = doc.term_vectors[@term]

            ret[key] += vec[:tf] if vec
          end

          progress && progress.call(50 + (i.to_f / total.to_f * 50.0).to_i)
        end

        progress && progress.call(100)

        ret
      end
    end
  end
end
