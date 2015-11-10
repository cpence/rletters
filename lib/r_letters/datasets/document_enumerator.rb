
module RLetters
  module Datasets
    # An enumerator for documents in a dataset
    #
    # This enumerator is clever enough to do its SQL finds in batches and similar
    # kinds of tricks.  It returns document objects taken from the dataset.
    #
    # @!attribute dataset
    #   @return [Dataset] The dataset to enumerate
    # @!attribute fl
    #   @return [String] Fields to return in documents. Should be a
    #     comma-separated list
    # @!attribute fulltext
    #   @return [Boolean] If true, return document full text. Defaults to false
    # @!attribute term_vectors
    #   @return [Boolean] If true, return term vectors
    class DocumentEnumerator
      include Virtus.model(strict: true, required: false)
      include Enumerable

      attribute :dataset, Dataset, required: true
      attribute :term_vectors, Boolean, default: false
      attribute :fulltext, Boolean, default: false
      attribute :fl, String

      # How many documents are in the dataset?
      #
      # @return [Integer] size of the dataset
      def size
        @dataset.entries.size
      end

      # Iterate over the documents in the dataset
      #
      # @yield [Document] Gives each document in the dataset to the block.
      # @return [void]
      def each
        return to_enum(:each) unless block_given?

        dataset.entries.find_in_batches(batch_size: batch_size) do |group|
          search_result = RLetters::Solr::Connection.search(search_query_for(group))

          # :nocov:
          unless search_result.num_hits == group.size
            fail RuntimeError, "Failed to get batch of results in DocumentEnumerator (wanted #{group.size} hits, got #{search_result.num_hits})"
          end
          # :nocov:

          search_result.documents.each { |doc| yield(doc) }
        end
      end

      private

      # Get the batch size
      #
      # This function memoizes the value for speed.
      #
      # @return [Integer] batch size for database queries
      def batch_size
        @batch_size ||= if term_vectors || fulltext
                          # We've been hitting trouble here with timeouts on
                          # these larger fetches; try throttling
                          50
                        else
                          1000
                        end
      end

      # Generate a Solr query for looking up this group
      #
      # @param [Array<Datasets::Entry>] group group of results to query
      # @return [Hash] Solr query parameters
      def search_query_for(group)
        { q: "uid:(#{group.map { |e| "\"#{e.uid}\"" }.join(' OR ')})",
          def_type: 'lucene',
          facet: false,
          fl: if fl
                fl
              else
                if fulltext
                  RLetters::Solr::Connection::DEFAULT_FIELDS_FULLTEXT
                else
                  RLetters::Solr::Connection::DEFAULT_FIELDS
                end
              end,
          tv: term_vectors,
          rows: group.size }
      end
    end
  end
end
