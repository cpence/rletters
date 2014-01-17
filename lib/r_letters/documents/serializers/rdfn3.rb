# -*- encoding : utf-8 -*-
require 'rdf/n3'

module RLetters
  module Documents
    module Serializers
      # Convert a document to an RDF/N3 record
      class RDFN3
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
          'RDF/N3'
        end

        # Return a URL where information about this serializer can be found
        #
        # @return [String] URL for information about this format
        def self.url
          'http://www.w3.org/DesignIssues/Notation3.html'
        end

        # Returns this document as RDF+N3
        #
        # @note No tests for this method, as it is implemented by the RDF gem.
        # @api public
        # @return [String] document in RDF+N3 format
        # @example Download this document as a n3 file
        #   controller.send_data(
        #     RLetters::Documents::Serializers::RDFN3.new(doc).serialize,
        #     filename: 'export.n3', disposition: 'attachment'
        #   )
        # :nocov:
        def serialize
          ::RDF::Writer.for(:n3).buffer do |writer|
            if @doc.is_a? Document
              writer << RDF.new(@doc).serialize
            else
              writer << @doc.each { |d| RDF.new(@doc).serialize }
            end
          end
        end
        # :nocov:
      end
    end
  end
end
