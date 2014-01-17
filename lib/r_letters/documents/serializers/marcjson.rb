# -*- encoding : utf-8 -*-

module RLetters
  module Documents
    module Serializers
      # Convert a document to a MARC record
      class MARCJSON
        # Create a serializer
        #
        # @api public
        # @param document_or_array [Document Array<Document>] a document or
        #   array of documents to serialize
        def initialize(document_or_array)
          case document_or_array
          when Array
            document_or_array.each do |x|
              unless x.is_a? Document
                fail ArgumentError, 'Array includes non-Document elements'
              end
            end
            @doc = document_or_array
          when Document
            @doc = document_or_array
          else
            fail ArgumentError, 'Cannot serialize a non-Document class'
          end
        end

        # Return the user-friendly name of the serializer
        #
        # @return [String] name of the serializer
        def self.format
          'MARC-in-JSON'
        end

        # Return a URL where information about this serializer can be found
        #
        # @return [String] URL for information about this format
        def self.url
          'http://www.oclc.org/developer/content/marc-json-draft-2010-03-11'
        end

        # Returns this document in MARC JSON format
        #
        # MARC in JSON is the newest and shiniest way to transmit MARC records.
        #
        # @note No tests for this method, as it is implemented by the MARC gem.
        # @api public
        # @return [String] document in MARC JSON format
        # @example Download this document as a MARC-JSON file
        #   controller.send_data(
        #     RLetters::Documents::Serializers::MARCJSON.new(doc),
        #     filename: 'export.json', disposition: 'attachment'
        #   )
        # :nocov
        def serialize
          if @doc.is_a? Document
            MARCRecord.new(@doc).serialize.to_hash.to_json
          else
            @doc.map { |d| MARCRecord.new(d).serialize.to_hash }.to_json
          end
        end
        # :nocov
      end
    end
  end
end
