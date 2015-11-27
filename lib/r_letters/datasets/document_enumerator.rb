
module RLetters
  module Datasets
    # An enumerator for documents in a dataset
    #
    # This enumerator returns document objects taken from the dataset.
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
        @dataset.document_count
      end

      # Iterate over the documents in the dataset
      #
      # @yield [Document] Gives each document in the dataset to the block.
      # @return [void]
      def each
        return to_enum(:each) unless block_given?

        dataset.queries.each do |query|
          query_size = query.size
          fetched = 0
          cursor_mark = '*'

          while fetched < query_size
            to_fetch = [query_size - fetched, batch_size].min

            search_result = query.search(
              cursor_mark: cursor_mark,
              sort: 'uid asc',
              rows: to_fetch,
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
              tv: term_vectors)

            # :nocov:
            unless search_result.num_hits == to_fetch
              fail "Failed to get batch of results in DocumentEnumerator (wanted #{to_fetch} hits, got #{search_result.num_hits})"
            end

            if cursor_mark == search_result.solr_response['nextCursorMark']
              fail 'Expected more hits, but received the same cursor in response'
            end
            # :nocov:

            search_result.documents.each { |doc| yield(doc) }

            cursor_mark = search_result.solr_response['nextCursorMark']
            fetched += to_fetch
          end
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
                          # These larger searches that include term vectors
                          # and full text just take longer to transmit down
                          # the wire, and have caused Solr timeouts.
                          50
                        else
                          1000
                        end
      end
    end
  end
end
