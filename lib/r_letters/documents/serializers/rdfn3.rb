require 'r_letters/documents/serializers/rdf'
require 'rdf/n3'

module RLetters
  module Documents
    module Serializers
      # Convert a document to an RDF/N3 record
      class RDFN3
        # Create a serializer
        #
        # @param document_or_array [Document Array<Document>] a document or
        #   array of documents to serialize
        def initialize(document_or_array)
          @doc = document_or_array
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
        # @return [String] document in RDF+N3 format
        # :nocov:
        def serialize
          ::RDF::Writer.for(:n3).buffer do |writer|
            if @doc.is_a? Enumerable
              writer << @doc.each { |d| RDF.new(d).serialize }
            else
              writer << RDF.new(@doc).serialize
            end
          end
        end
        # :nocov:
      end
    end
  end
end
