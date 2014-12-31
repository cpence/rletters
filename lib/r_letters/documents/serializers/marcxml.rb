require 'marc'

module RLetters
  module Documents
    module Serializers
      # Convert a document to a MARC-XML record
      class MARCXML
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
          'MARCXML'
        end

        # Return a URL where information about this serializer can be found
        #
        # @return [String] URL for information about this format
        def self.url
          'http://www.loc.gov/standards/marcxml/'
        end

        # Returns this document as MARC-XML
        #
        # @note No tests for this method, as it is implemented by the MARC gem.
        # @return [String] the document as a MARC-XML document
        # :nocov:
        def serialize
          if @doc.is_a? Enumerable
            doc = Nokogiri::XML::Document.new
            node = Nokogiri::XML::Node.new('collection', doc)
            node.add_namespace_definition(nil, 'http://www.loc.gov/MARC21/slim')
            doc.root = node

            @doc.map { |d| node.add_child(do_serialize(d, false).root) }

            doc.to_xml(indent: 2)
          else
            do_serialize(@doc, true).to_xml(indent: 2)
          end
        end
        # :nocov:

        private

        # Do the serialization for an individual document
        #
        # @param [Document] doc the document to serialize
        # @return [Nokogiri::XML::Node] single document serialized as a MARCXML
        #   element
        #
        # :nocov:
        def do_serialize(doc, include_namespace = true)
          # This uses REXML, and there's nothing for it but to write it out and
          # convert it back to Nokogiri
          rexml_element = ::MARC::XMLWriter.encode(
            MARCRecord.new(doc).serialize,
            include_namespace: include_namespace
          )
          xml = ''
          formatter = REXML::Formatters::Default.new
          formatter.write(rexml_element, xml)

          Nokogiri::XML::Document.parse(xml)
        end
        # :nocov:
      end
    end
  end
end
