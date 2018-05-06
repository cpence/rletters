# frozen_string_literal: true

module RLetters
  module Solr
    # Parse the term vectors returned from Solr
    #
    # This class is reponsible for converting Solr's obtuse term vectors into
    # a +Hash+ based format that is much easier to actually use.
    #
    # Example of the Solr term vector format:
    #
    #   [ 'doc-N', [ 'uniqueKey', 'uid',
    #     'fulltext', [
    #       'term', [
    #         'tf', 1,
    #         'offsets', ['start', 100, 'end', 110],
    #         'positions', ['position', 50],
    #         'df', 1,
    #         'tf-idf', 0.234],
    #       'term2', ... ]]]
    class ParseTermVectors
      # Parse term vectors from a Solr search
      #
      # @param [Array] term_vectors the term vectors returned by Solr
      def initialize(term_vectors)
        @term_vectors = term_vectors
      end

      # Return the term vectors for the given document
      #
      # @return [Hash] term vectors as stored in +Document#term_vectors+
      # @see Document#term_vectors
      def for_document(uid)
        array = array_for_document(uid)
        array ? parse_array(array) : {}
      end

      private

      # Return the term vector array for the given document
      #
      # The term vectors returned by Solr include elements for every document
      # returned in a search. This function extracts the one corresponding to
      # the given uid.
      #
      # @param [String] uid the UID of the document to locate terms for
      # @return [Array] the Solr term vector array for this document
      def array_for_document(uid)
        @term_vectors.each_slice(2).each do |(_, array)|
          _, tv_uid, _, vectors = array
          next unless tv_uid == uid

          if !vectors.is_a?(Array) || vectors.empty?
            return nil
          else
            return vectors
          end
        end
      end

      # Parse the term vector array format returned by Solr
      #
      # This function expects to be passed the array following 'fulltext' in
      # the above example, present for each document in the search at
      # +solr_response['termVectors'][N + 1][3]+.
      #
      # @note Right now, the function does not parse the +offsets+ or +tfidf+
      # values here, because those are disabled in the default RLetters
      # schema. Uncomment them here if you need them.
      #
      # @param [Array] array the Solr term vector array
      # @return [Hash] term vectors as stored in +Document#term_vectors+
      # @see Document#term_vectors
      def parse_array(array)
        {}.tap do |ret|
          array.each_slice(2) do |(term, attr_array)|
            ret[term] = attr_array.each_slice(2).each_with_object({}) do |(key, val), hash|
              case key
              when 'tf'
                hash[:tf] = Integer(val)
              when 'positions'
                hash[:positions] = parse_position_list(val)
              when 'df'
                hash[:df] = Float(val)
              end
              # when 'offsets'
              #   hash[:offsets] = parse_offset_list(val)
              # when 'tf-idf'
              #   hash[:tfidf] = Float(val)
            end
          end
        end
      end

      # Parse a list of offsets as returned by Solr
      #
      # When Solr returns offsets, it does so in an array, which looks like:
      #   ['start', 12, 'end', 34, 'start', 56, 'end', 78, ...]
      # We parse that into Range values here.
      #
      # @note This function is commented out as we're not currently using
      # the offsets anywhere in RLetters. They're disabled in the default
      # schema.
      #
      # @param [Array] val the values to parse
      # @return [Array<Range>]  the array of offset ranges
      # def parse_offset_list(val)
      #   val.each_slice(4).map do |(label, s, label2, e)|
      #     (Integer(s)...Integer(e))
      #   end
      # end

      # Parse a list of term positions as returned by Solr
      #
      # When Solr returns positions, it does so in an array, which looks like:
      #   ['position', 1, 'position', 2, 'position', 3, ...]
      # We remove those labels here and convert into an array of integers.
      #
      # @param [Array] val the values to parse
      # @return [Array<Integer>] the array of term positions
      def parse_position_list(val)
        val.each_slice(2).map do |(_, position)|
          Integer(position)
        end
      end
    end
  end
end
