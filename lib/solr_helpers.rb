# -*- encoding : utf-8 -*-

# Code for parsing Solr's Ruby response format
module SolrHelpers
  
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
      term.force_encoding(Encoding::UTF_8)
      attr_array = tvec_array[i+1]
      hash = {}
      
      (0...attr_array.length).step(2) do |j|
        key = attr_array[j]
        val = attr_array[j+1]
        
        case key
        when 'tf'
          hash[:tf] = Integer(val)
        when 'offsets'
          hash[:offsets] = []
          (0...val.length).step(4) do |k|
            s = Integer(val[k+1])
            e = Integer(val[k+3])
            hash[:offsets] << (s...e)
          end
        when 'positions'
          hash[:positions] = []
          (0...val.length).step(2) do |k|
            p = Integer(val[k+1])
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
