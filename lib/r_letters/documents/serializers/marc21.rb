require 'r_letters/documents/serializers/marc_record'

module RLetters
  module Documents
    module Serializers
      # Convert a document to a MARC21 transmission record
      class MARC21
        # Create a serializer
        #
        # @param document [Document] a document to serialize
        def initialize(document)
          @doc = document
        end

        # Return the user-friendly name of the serializer
        #
        # @return [String] name of the serializer
        def self.format
          'MARC21'
        end

        # Return a URL where information about this serializer can be found
        #
        # @return [String] URL for information about this format
        def self.url
          'http://www.loc.gov/marc/'
        end

        # Returns this document in MARC21 transmission format
        #
        # @note No tests for this method, as it is implemented by the MARC gem.
        # @return [String] document in MARC21 transmission format
        # :nocov
        def serialize
          MARCRecord.new(@doc).serialize.to_marc
        end
        # :nocov
      end
    end
  end
end
