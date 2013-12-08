# -*- encoding : utf-8 -*-

module Solr
  module DataHelpers
    # Methods to query the size of the Solr corpus
    module CorpusSize
      extend ActiveSupport::Concern

      module ClassMethods
        # Return the size of the entire Solr corpus
        #
        # Returns nil if there is an error connecting to the Solr database.
        #
        # @return [Integer] number of documents in the corpus
        # @example Get the Solr corpus size
        #   Solr::DataHelpers.corpus_size
        #   # => 1043
        def corpus_size
          solr_query = { q: '*:*',
                         def_type: 'lucene',
                         rows: 1,
                         start: 0 }

          Solr::Connection.search(solr_query).num_hits
        rescue Solr::ConnectionError
          nil
        end
      end
    end
  end
end
