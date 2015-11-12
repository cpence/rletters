require 'marc'

module RLetters
  module Documents
    module Serializers
      # Convert a document to a MARC-XML record
      class MARCXML < MARCRecord
        define_single(:marcxml, 'MARCXML',
                      'http://www.loc.gov/standards/marcxml/') do |docs|
          if docs.is_a? Enumerable
            doc = Nokogiri::XML::Document.new
            node = Nokogiri::XML::Node.new('collection', doc)
            node.add_namespace_definition(nil, 'http://www.loc.gov/MARC21/slim')
            doc.root = node

            docs.map { |d| node.add_child(to_marc_xml(d, false).root) }

            doc.to_xml(indent: 2)
          else
            to_marc_xml(docs, true).to_xml(indent: 2)
          end
        end

        private

        # Do the serialization for an individual document
        #
        # @param [Document] doc the document to serialize
        # @return [Nokogiri::XML::Node] single document serialized as a MARCXML
        #   element
        #
        # :nocov:
        def to_marc_xml(doc, include_namespace = true)
          # This uses REXML, and there's nothing for it but to write it out and
          # convert it back to Nokogiri
          rexml_element = ::MARC::XMLWriter.encode(
            to_marc_record(doc),
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
