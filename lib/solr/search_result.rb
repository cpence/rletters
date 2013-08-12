# -*- encoding : utf-8 -*-

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
  #       Document.facets[:authors_facet] = Array<Array>
  #         Document.facets[:authors_facet][0] = ['Some Author', Integer]
  #       Document.facets[:journal_facet] = Array<Array>
  #         Document.facets[:journal_facet][0] = ['Some Journal', Integer]
  #       Document.facets[:year]
  #         Document.facets[:year][0] = ['1940–1949', Integer]
  #
  #   @example Get the number of documents published by W. Shatner
  #     shatner_docs = Document.facets[:authors_facet].assoc('W. Shatner')[1]
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
  #     result.documents.count > result.num_hits
  #
  # @!attribute [r] documents
  #   @return [Array<Document>] the documents found by the last search
  # @!attribute [r] solr_response
  #   @return [RSolr::Ext::Response] the raw Solr search response
  class SearchResult

    attr_reader :facets, :num_hits, :documents, :solr_response

    # Create a search result from a Solr response
    #
    # @param [RSolr::Ext::Response] response the returned Solr response
    # @raise [StandardError] if the Solr server returned an invalid response
    def initialize(response)
      # Initialize all our variables
      @solr_response = response

      @num_hits = 0
      @num_hits = response.total if response.ok?

      @documents = []
      @facets = nil

      # Raise an error if Solr does not respond
      raise StandardError.new('Solr server did not respond') unless solr_response.ok?
      return if solr_response.total == 0
      raise StandardError.new('Solr server claimed to have documents, but returned an empty array') unless solr_response.docs && solr_response.docs.count

      # Make sure that we set the encoding on all the returned Solr strings
      solr_response.to_utf8!

      # Make the documents
      solr_response.docs.each do |doc|
        # See if there are term vectors in this search
        if solr_response['termVectors']
          (0...solr_response['termVectors'].length).step(2) do |i|
            shasum = solr_response['termVectors'][i + 1][1]
            next unless doc['shasum'] == shasum

            tv = parse_term_vectors(solr_response['termVectors'][i + 1][3])
            doc['term_vectors'] = tv
          end
        end

        # Make the document
        @documents << Document.new(doc)
      end

      # See if the facets are available, and set them if so
      if solr_response.facets || solr_response.facet_queries
        @facets = Solr::Facets.new(solr_response.facets,
                                   solr_response.facet_queries)
      end
    end

    private

    # Parse the term vector array format returned by Solr
    #
    # Example of the Solr term vector format:
    #
    #   [ 'doc-N', [ 'uniqueKey', 'shasum',
    #     'fulltext', [
    #       'term', [
    #         'tf', 1,
    #         'offsets', ['start', 100, 'end', 110],
    #         'positions', ['position', 50],
    #         'df', 1,
    #         'tf-idf', 0.234],
    #       'term2', ... ]]]
    #
    # This function expects to be passed the array following 'fulltext' in the
    # above example, present for each document in the search at
    # +solr_response['termVectors'][N + 1][3]+.
    #
    # @api public
    # @param [Array] tvec_array the Solr term vector array
    # @return [Hash] term vectors as stored in +Document#term_vectors+
    # @see Document#term_vectors
    # @example Convert the term vectors for the first document in the response
    #   doc.term_vectors = parse_term_vectors(solr_response['termVectors'][1][3])
    def parse_term_vectors(tvec_array)
      term_vectors = {}

      (0...tvec_array.length).step(2) do |i|
        term = tvec_array[i]
        attr_array = tvec_array[i + 1]
        hash = {}

        (0...attr_array.length).step(2) do |j|
          key = attr_array[j]
          val = attr_array[j + 1]

          case key
          when 'tf'
            hash[:tf] = Integer(val)
          when 'offsets'
            hash[:offsets] = []
            (0...val.length).step(4) do |k|
              s = Integer(val[k + 1])
              e = Integer(val[k + 3])
              hash[:offsets] << (s...e)
            end
          when 'positions'
            hash[:positions] = []
            (0...val.length).step(2) do |k|
              p = Integer(val[k + 1])
              hash[:positions] << p
            end
          when 'df'
            hash[:df] = Float(val)
          when 'tf-idf'
            hash[:tfidf] = Float(val)
          end
        end

        term_vectors[term] = hash
      end

      term_vectors
    end

  end

end
