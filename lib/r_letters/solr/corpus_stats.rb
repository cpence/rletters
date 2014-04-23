# -*- encoding : utf-8 -*-

module RLetters
  module Solr
    # Methods to query information about the entire Solr corpus
    class CorpusStats
      # Return the size of the Solr corpus
      #
      # Returns nil if there is an error connecting to the Solr database.
      #
      # @return [Integer] number of documents in the corpus
      # @example Get the Solr corpus size
      #   RLetters::Solr::CorpusStats.new.size
      #   # => 1234
      def size
        solr_query = { q: '*:*',
                       def_type: 'lucene',
                       rows: 0 }

        Connection.search(solr_query).num_hits
      rescue ConnectionError
        nil
      end
    end
  end
end
