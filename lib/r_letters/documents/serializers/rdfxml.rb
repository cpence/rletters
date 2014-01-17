# -*- encoding : utf-8 -*-
require 'rdf/n3'

module RLetters
  module Documents
    module Serializers
      # Convert a document to an RDF/XML record
      class RDFXML
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
          'RDF/XML'
        end

        # Return a URL where information about this serializer can be found
        #
        # @return [String] URL for information about this format
        def self.url
          'http://www.w3.org/TR/rdf-syntax-grammar/'
        end


        # Returns this document as RDF+XML
        #
        # @api public
        # @return [String] document in RDF+XML format
        # @example Download this document as an XML file
        #   controller.send_data(
        #     RLetters::Documents::Serializers::RDFXML.new(doc).serialize,
        #     filename: 'export.xml', disposition: 'attachment'
        #   )
        def serialize
          doc = Nokogiri::XML::Document.new
          rdf = Nokogiri::XML::Node.new('rdf', doc)

          doc.add_child(rdf)
          rdf.default_namespace = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
          rdf.add_namespace_definition('dc', 'http://purl.org/dc/terms/')

          if @doc.is_a? Document
            rdf.add_child(do_serialize(@doc, doc))
          else
            @doc.each { |d| rdf.add_child(do_serialize(d, doc)) }
          end

          doc.to_xml(indent: 2)
        end

        private

        # Returns this document as an rdf:Description element
        #
        # @api private
        # @param doc [Document] the document to serialize
        # @param xml_doc [Nokogiri::XML::Document] the XML document to add the
        #   node to
        # @return [Nokogiri::XML::Node] document in RDF+XML format
        def do_serialize(doc, xml_doc)
          desc = Nokogiri::XML::Node.new('Description', xml_doc)

          RDF.new(doc).serialize.each_statement do |statement|
            # I have no idea when these errors might happen, so I can't spec for
            # them, but I'm catching them just to be safe.
            # :nocov:
            qname = statement.predicate.qname
            unless qname
              Rails.logger.warn "Cannot get qualified name for #{statement.predicate.to_s}, skipping predicate"
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
