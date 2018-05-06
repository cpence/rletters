# frozen_string_literal: true
require 'r_letters/documents/serializers/rdf'
require 'rdf/n3'

module RLetters
  module Documents
    module Serializers
      # Convert a document to an RDF/XML record
      class RDFXML < RDF
        define_single(:rdf, 'RDF/XML',
                      'http://www.w3.org/TR/rdf-syntax-grammar/') do |docs|
          doc = Nokogiri::XML::Document.new
          rdf = Nokogiri::XML::Node.new('rdf', doc)

          doc.add_child(rdf)
          rdf.default_namespace = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
          rdf.add_namespace_definition('dc', 'http://purl.org/dc/terms/')

          if docs.is_a? Enumerable
            docs.each { |d| rdf.add_child(to_rdf_xml(d, doc)) }
          else
            rdf.add_child(to_rdf_xml(docs, doc))
          end

          doc.to_xml(indent: 2)
        end

        private

        # Returns this document as an rdf:Description element
        #
        # @param doc [Document] the document to serialize
        # @param xml_doc [Nokogiri::XML::Document] the XML document to add the
        #   node to
        # @return [Nokogiri::XML::Node] document in RDF+XML format
        def to_rdf_xml(doc, xml_doc)
          desc = Nokogiri::XML::Node.new('Description', xml_doc)

          to_rdf_graph(doc).each_statement do |statement|
            # I have no idea when these errors might happen, so I can't spec for
            # them, but I'm catching them just to be safe.
            # :nocov:
            qname = statement.predicate.qname
            unless qname
              Rails.logger.warn "Cannot get qualified name for #{statement.predicate}, skipping predicate"
              next
            end

            unless statement.object.literal?
              Rails.logger.warn "Object #{statement.object.inspect} is not a literal, cannot parse"
              next
            end
            # :nocov:

            node = Nokogiri::XML::Node.new("#{qname[0]}:#{qname[1]}", xml_doc)
            node.content = statement.object.value

            if statement.object.has_datatype?
              node['datatype'] = statement.object.datatype.to_s
            end

            desc.add_child(node)
          end

          desc
        end
      end
    end
  end
end
