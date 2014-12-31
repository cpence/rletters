
module RLetters
  module Datasets
    # An enumerator for documents in a dataset
    #
    # This enumerator is clever enough to do its SQL finds in batches and similar
    # kinds of tricks.  It returns document objects taken from the dataset.
    class DocumentEnumerator
      include Enumerable

      # Create a new document enumerator
      #
      # @param [Dataset] dataset the dataset to enumerate
      # @param [Hash] options options for finding the documents
      # @option options [String] :fl fields to return in documents
      # @option options [Boolean] :fulltext if true, return document full text
      # @option options [Booelan] :term_vectors if true, return term vectors
      def initialize(dataset, options = {})
        @dataset = dataset
        @options = options

        if @options[:term_vectors] || @options[:fulltext]
          # We've been hitting trouble here with timeouts on these larger
          # fetches; try throttling
          @batch_size = 10
        else
          @batch_size = 1000
        end
      end

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

        @dataset.entries.find_in_batches(batch_size: @batch_size) do |group|
          search_result = RLetters::Solr::Connection.search(search_query_for(group))

          # :nocov:
          unless search_result.num_hits == group.size
            fail "Failed to get batch of results in DocumentEnumerator (wanted #{group.size} hits, got #{search_result.num_hits})"
          end
          # :nocov:

          search_result.documents.each { |doc| yield(doc) }
        end
      end

      private

      # Generate a Solr query for looking up this group
      #
      # @param [Array<Datasets::Entry>] group group of results to query
      # @return [Hash] Solr query parameters
      def search_query_for(group)
        { q: "uid:(#{group.map { |e| "\"#{e.uid}\"" }.join(' OR ')})",
          def_type: 'lucene',
          facet: false,
          fl: if @options[:fl]
                @options[:fl]
              else
                if @options[:fulltext]
                  RLetters::Solr::Connection::DEFAULT_FIELDS_FULLTEXT
                else
                  RLetters::Solr::Connection::DEFAULT_FIELDS
                end
              end,
          tv: @options[:term_vectors] || false,
          rows: group.size }
      end
    end
  end
end
