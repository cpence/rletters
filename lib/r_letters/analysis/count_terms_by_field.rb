# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    # Code for counting the occurrences of a term in a dataset, grouped
    class CountTermsByField
      # Create a new object for counting terms in a datset by field
      #
      # Pass the term that you're interested to analyze, and the dataset that
      # you'd like to draw the term from (or `nil` to indicate the entire
      # corpus).
      #
      # @api public
      # @param [String] term the term of interest
      # @param [Dataset] dataset the dataset to analyze (or `nil`)
      # @param [Proc] progress If set, a function to call with a percentage of
      #   completion (one `Integer` parameter)
      # @example Create a new analyzer to count 'test' in the whole corpus
      #   analyzer = RLetters::Analysis::CountTermsByField.new(
      #     'test',
      #     nil,
      #     ->(p) { puts "PROGRESS IS NOW #{p}%" }
      #   )
      def initialize(term, dataset = nil, progress = nil)
        @term = term
        @dataset = dataset
        @progress = progress
      end

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
      # @param [Symbol] field field to group by
      # @return [Hash<String, Integer>] number of documents in each grouping
      # @example Group a dataset by year of publication
      #   RLetters::Analysis::CountArticlesByField.new(dataset).counts_for(:year)
      #   # => { '1940' => 3, '1941' => 5, ... }
      def counts_for(field)
        uids = @dataset ? grouped_uids_dataset(@dataset, field) :
                          grouped_uids_corpus(field)

        uids_to_term_counts(uids)
      end

      private

      # Group the UIDs in a dataset manually by field
      #
      # @api private
      # @param [Dataset] dataset set to group
      # @param [Symbol] field field to group by
      # @return [Hash<String, Array<String>>] list of UIDs for each group
      def grouped_uids_dataset(dataset, field)
        ret = {}
        total = dataset.entries.size

        enum = RLetters::Datasets::DocumentEnumerator.new(dataset)
        enum.each_with_index do |doc, i|
          key = get_field_for_grouping(doc, field)
          ret[key] ||= []
          ret[key] << doc.uid

          @progress && @progress.call((i.to_f / total.to_f * 50.0).to_i)
        end

        @progress && @progress.call(50)

        ret
      end

      # Group the UIDs in the entire corpus by field
      #
      # @api private
      # @param [Symbol] field field to group by
      # @return [Hash<String, Array<String>>] list of UIDs for each group
      def grouped_uids_corpus(field)
        ret = {}
        start = 0

        num_docs = 0
        total_docs = RLetters::Solr::CorpusStats.new.size

        loop do
          group_result = RLetters::Solr::Connection.search_raw({
            q: '*:*',
            def_type: 'lucene',
            group: 'true',
            'group.field' => field.to_s,
            fl: 'uid',
            facet: 'false',
            start: start.to_s,
            rows: 1
          })

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

          uids_result = RLetters::Solr::Connection.search_raw({
            q: '*:*',
            def_type: 'lucene',
            group: 'true',
            'group.field' => field.to_s,
            fl: 'uid',
            facet: 'false',
            start: start.to_s,
            rows: 1,
            'group.limit' => group_size
          })

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
          if @progress
            num_docs += group_size
            @progress.call((num_docs.to_f / total_docs.to_f * 50.0).to_i)
          end
        end

        @progress && @progress.call(50)

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

      # Convert a list of grouped UIDs to term counts
      #
      # Query all the documents listed, get their counts for the term of
      # interest, and return them as a new hash.
      #
      # @api private
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

          @progress && @progress.call(50 + (i.to_f / total.to_f * 50.0).to_i)
        end

        @progress && @progress.call(100)

        ret
      end
    end
  end
end
