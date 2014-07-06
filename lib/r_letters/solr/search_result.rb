# -*- encoding : utf-8 -*-

module RLetters
  module Solr
    # An object representing the result of a search against the Solr database
    #
    # @!attribute [r] facets
    #   Faceted browsing information that was returned by the last search
    #
    #   For the purposes of faceted browsing, the Solr server (as configured by
    #   default in RLetters) returns the number of items within the current
    #   search with each author, journal, or publication decade.
    #
    #   @api public
    #   @return [Hash] facets returned by the last search, +nil+ if none.
    #     The hash contains the following keys:
    #       result.facets[:authors_facet] = Array<Array>
    #         result.facets[:authors_facet][0] = ['Some Author', Integer]
    #       result.facets[:journal_facet] = Array<Array>
    #         result.facets[:journal_facet][0] = ['Some Journal', Integer]
    #       result.facets[:year]
    #         result.facets[:year][0] = ['1940–1949', Integer]
    #
    #   @example Get the number of documents published by W. Shatner
    #     shatner_docs = result.facets[:authors_facet].assoc('W. Shatner')[1]
    #
    # @!attribute [r] num_hits
    #   Number of documents returned by the last search
    #
    #   Since the search results (i.e., the size of the +@documents+ variable
    #   for a given view) are almost always limited by the per-page count,
    #   this variable returns the full number of documents that were returned by
    #   the last search.
    #
    #   @api public
    #   @return [Integer] number of documents in the last search
    #   @example Returns true if there are more hits than documents returned
    #     result.documents.size > result.num_hits
    #
    # @!attribute [r] documents
    #   @return [Array<Document>] the documents found by the last search
    # @!attribute [r] solr_response
    #   @return [RSolr::Ext::Response] the raw Solr search response
    # @!attribute [r] params
    #   @return [Hash] the parameters used for this search, as parsed and
    #     returned by Solr
    class SearchResult
      attr_reader :facets, :num_hits, :documents, :solr_response, :params

      # Create a search result from a Solr response
      #
      # @param [RSolr::Ext::Response] response the returned Solr response
      # @raise [ConnectionError] if the Solr server returned an invalid
      #   response
      def initialize(response)
        # Initialize all our variables
        @solr_response = response

        @num_hits = 0
        @num_hits = response.total if response.ok?

        @params = response.params

        @documents = []
        @facets = nil

        # Raise an error if Solr does not respond
        unless solr_response.ok?
          fail ConnectionError, 'Solr server returned nothing or failed request'
        end
        return if solr_response.total == 0

        # Make sure that we set the encoding on all the returned Solr strings
        solr_response.to_utf8!

        # Make the documents
        term_vectors = solr_response['termVectors']
        solr_response.docs.each do |doc|
          # See if there are term vectors in this search
          if term_vectors
            @parser ||= ParseTermVectors.new(term_vectors)
            doc['term_vectors'] = @parser.for_document(doc['uid'])
          end

          # Make the document
          @documents << Document.new(doc)
        end

        # See if the facets are available, and set them if so
        if solr_response.facets || solr_response.facet_queries
          @facets = Facets.new(solr_response.facets,
                               solr_response.facet_queries)
        end
      end
    end
  end
end
