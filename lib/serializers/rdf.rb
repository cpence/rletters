# -*- encoding : utf-8 -*-

require 'rdf/n3'

module Serializers

  # Convert a document to an RDF record
  module RDF

    # Register this serializer in the Document list
    def self.included(base)
      base.register_serializer(
        :rdf, 'RDF/XML',
        ->(doc) { doc.to_rdf_xml.to_xml(indent: 2) },
        'http://www.w3.org/TR/rdf-syntax-grammar/'
      )
      base.register_serializer(
        :n3, 'RDF/N3',
        ->(doc) { doc.to_rdf_n3 },
        'http://www.w3.org/DesignIssues/Notation3.html'
      )
    end

    # Returns this document as a RDF::Graph object
    #
    # For the moment, we provide only metadata items for the basic Dublin
    # Core elements, and for the Dublin Core
    # {"bibliographicCitation"
    # element.}[http://dublincore.org/documents/dc-citation-guidelines/]
    # We also encode an OpenURL reference (using the standard OpenURL
    # namespace), in a second bibliographicCitation element.  The precise way
    # to encode journal articles in DC is in serious flux, but this should
    # provide a reasonable solution.
    #
    # @api public
    # @return [RDF::Graph] document as a RDF graph
    # @example Convert this document to RDF-Turtle
    #   RDF::Writer.for(:turtle).buffer do |writer|
    #     writer << doc.to_rdf
    #   end
    def to_rdf
      graph = ::RDF::Graph.new
      doc = ::RDF::Node.new

      unless formatted_author_list.nil?
        formatted_author_list.each do |a|
          name = ''
          name << "#{a.von} " unless a.von.blank?
          name << "#{a.last}"
          name << " #{a.suffix}" unless a.suffix.blank?
          name << ", #{a.first}"
          graph << [doc, ::RDF::DC.creator, name]
        end
      end
      graph << [doc, ::RDF::DC.issued, year] unless year.blank?

      citation = "#{journal}" unless journal.blank?
      citation << " #{volume}" unless volume.blank?
      citation << ' ' if volume.blank?
      citation << "(#{number})" unless number.blank?
      citation << ", #{pages}" unless pages.blank?
      citation << ". (#{year})" unless year.blank?
      graph << [doc, ::RDF::DC.bibliographicCitation, citation]

      ourl = ::RDF::Literal.new(
        '&' + to_openurl_params,
        datatype: ::RDF::URI.new('info:ofi/fmt:kev:mtx:ctx')
      )
      graph << [doc, ::RDF::DC.bibliographicCitation, ourl]

      graph << [doc, ::RDF::DC.relation, journal] unless journal.blank?
      graph << [doc, ::RDF::DC.title, title] unless title.blank?
      graph << [doc, ::RDF::DC.type, 'Journal Article']
      graph << [doc, ::RDF::DC.identifier, "info:doi/#{doi}"] unless doi.blank?

      graph
    end

    # Returns this document as RDF+N3
    #
    # @note No tests for this method, as it is implemented by the RDF gem.
    # @api public
    # @return [String] document in RDF+N3 format
    # @example Download this document as a n3 file
    #   controller.send_data doc.to_rdf_turtle, filename: 'export.n3',
    #                        disposition: 'attachment'
    # :nocov:
    def to_rdf_n3
      ::RDF::Writer.for(:n3).buffer do |writer|
        writer << to_rdf
      end
    end
    # :nocov:

    # Returns this document as an rdf:Description element
    #
    # @api private
    # @param [Nokogiri::XML::Document] doc the document to add the node to
    # @return [Nokogiri::XML::Node] document in RDF+XML format
    def to_rdf_xml_node(doc)
      desc = Nokogiri::XML::Node.new('Description', doc)

      to_rdf.each_statement do |statement|

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

        node = Nokogiri::XML::Node.new("#{qname[0]}:#{qname[1]}", doc)
        node.content = statement.object.value

        if statement.object.has_datatype?
          node['datatype'] = statement.object.datatype.to_s
        end

        desc.add_child(node)
      end

      desc
    end

    # Returns this document as RDF+XML
    #
    # @api public
    # @return [Nokogiri::XML::Document] document in RDF+XML format
    # @example Download this document as an XML file
    #   controller.send_data doc.to_rdf_xml.to_xml, filename: 'export.xml',
    #                        disposition: 'attachment'
    def to_rdf_xml
      doc = Nokogiri::XML::Document.new
      rdf = Nokogiri::XML::Node.new('rdf', doc)

      doc.add_child(rdf)
      rdf.default_namespace = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
      rdf.add_namespace_definition('dc', 'http://purl.org/dc/terms/')
      rdf.add_child(to_rdf_xml_node(doc))

      doc
    end

  end
end

# Ruby's standard Array class
class Array
  # Convert this array (of Document objects) to an RDF+N3 collection
  #
  # Only will work on arrays that consist entirely of Document objects, will
  # raise an ArgumentError otherwise.
  #
  # @api public
  # @return [String] array of documents as RDF+N3 collection
  # @note No tests for this method, as it is implemented by the RDF gem.
  # @example Save an array of documents in RDF+N3 format to stdout
  #   doc_array = Solr::Connection.search(...).documents
  #   $stdout.write(doc_array.to_rdf_n3)
  # :nocov:
  def to_rdf_n3
    each do |x|
      fail ArgumentError, 'No to_rdf method for array element' unless x.respond_to? :to_rdf
    end

    ::RDF::Writer.for(:n3).buffer do |writer|
      each do |x|
        writer << x.to_rdf
      end
    end
  end
  # :nocov:

  # Convert this array (of Document objects) to an RDF+XML collection
  #
  # Only will work on arrays that consist entirely of Document objects, will
  # raise an ArgumentError otherwise.
  #
  # @api public
  # @return [Nokogiri::XML::Document] array of documents as RDF+XML collection
  # @example Save an array of documents in RDF+XML format to stdout
  #   doc_array = Solr::Connection.search(...).documents
  #   $stdout.write(doc_array.to_rdf_xml)
  def to_rdf_xml
    each do |x|
      fail ArgumentError, 'No to_rdf method for array element' unless x.respond_to? :to_rdf
    end

    doc = Nokogiri::XML::Document.new
    rdf = Nokogiri::XML::Node.new('rdf', doc)

    doc.add_child(rdf)
    rdf.default_namespace = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
    rdf.add_namespace_definition('dc', 'http://purl.org/dc/terms/')

    each do |x|
      rdf.add_child(x.to_rdf_xml_node(doc))
    end

    doc
  end
end
