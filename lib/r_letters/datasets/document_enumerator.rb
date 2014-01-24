# -*- encoding : utf-8 -*-

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
      # @option options [String] fl fields to return in documents
      # @option options [Boolean] fulltext if true, return document full text
      def initialize(dataset, options = {})
        @dataset = dataset
        @options = options
      end

      # Iterate over the documents in the dataset
      #
      # @yield [Document] Gives each document in the dataset to the block.
      # @return [undefined]
      def each
        return to_enum(:each) unless block_given?

        @dataset.entries.find_in_batches do |group|
          search_result = RLetters::Solr::Connection.search(search_query_for(group))

          # :nocov:
          unless search_result.num_hits == group.count
            fail "Failed to get batch of results in DocumentEnumerator (wanted #{group.count} hits, got #{search_result.num_hits})"
          end
          # :nocov:

          search_result.documents.each { |doc| yield(doc) }
        end
      end

      private

      # Generate a Solr query for looking up this group
      #
      # @params [Array<Datasets::Entry>] group group of results to query
      # @return [Hash] Solr query parameters
      # @api private
      def search_query_for(group)
        { q: "uid:(#{group.map { |e| "\"#{e.uid}\"" }.join(' OR ')})",
          def_type: 'lucene',
          facet: false,
          fl: @options[:fl] ? @options[:fl] :
                (@options[:fulltext] ?
                  RLetters::Solr::Connection::DEFAULT_FIELDS_FULLTEXT :
                  RLetters::Solr::Connection::DEFAULT_FIELDS),
          rows: group.count }
      end
    end
  end
end
