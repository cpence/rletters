# -*- encoding : utf-8 -*-

module Solr
  module DataHelpers

    # Return the size of the entire Solr corpus
    #
    # Returns nil if there is an error connecting to the Solr database.
    #
    # @return [Integer] number of documents in the corpus
    # @example Get the Solr corpus size
    #   Solr::DataHelpers.corpus_size
    #   # => 1043
    def self.corpus_size
      solr_query = {}
      solr_query[:q] = '*:*'
      solr_query[:defType] = 'lucene'
      solr_query[:rows] = 1
      solr_query[:start] = 0

      Solr::Connection.search(solr_query).num_hits
    rescue Solr::ConnectionError
      nil
    end

  end
end
