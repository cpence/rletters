# -*- encoding : utf-8 -*-

require 'rdf/n3'
require 'rdf/rdfxml'

module Serializers

  # Convert a document to an RDF record
  module RDF

    # Register this serializer in the Document list
    def self.included(base)
      base.register_serializer(:rdf, 'RDF/XML', lambda { |doc| doc.to_rdf_xml },
        'http://www.w3.org/TR/rdf-syntax-grammar/')
      base.register_serializer(:n3, 'RDF/N3', lambda { |doc| doc.to_rdf_n3 },
        'http://www.w3.org/DesignIssues/Notation3.html')
    end

    # Returns this document as a RDF::Graph object
    #
    # For the moment, we provide only metadata items for the basic Dublin
    # Core elements, and for the Dublin Core
    # {"bibliographicCitation" element.}[http://dublincore.org/documents/dc-citation-guidelines/]
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

      ourl = ::RDF::Literal.new("&" + to_openurl_params, datatype: ::RDF::URI.new("info:ofi/fmt:kev:mtx:ctx"))
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
    #   controller.send_data doc.to_rdf_turtle, filename: 'export.n3', disposition: 'attachment'
    # :nocov:
    def to_rdf_n3
      ::RDF::Writer.for(:n3).buffer do |writer|
        writer << to_rdf
      end
    end
    # :nocov:

    # Returns this document as RDF+XML
    #
    # @note No tests for this method, as it is implemented by the RDF gem.
    # @api public
    # @return [String] document in RDF+XML format
    # @example Download this document as an XML file
    #   controller.send_data doc.to_rdf_xml, filename: 'export.xml', disposition: 'attachment'
    # :nocov:
    def to_rdf_xml
      ::RDF::Writer.for(:rdfxml).buffer do |writer|
        writer << to_rdf
      end
    end
    # :nocov:

  end
end

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
  #   doc_array = Document.find_all_by_solr_query(...)
  #   $stdout.write(doc_array.to_rdf_n3)
  # :nocov:
  def to_rdf_n3
    self.each do |x|
      raise ArgumentError, 'No to_rdf method for array element' unless x.respond_to? :to_rdf
    end

    ::RDF::Writer.for(:n3).buffer do |writer|
      self.each do |x|
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
  # @return [String] array of documents as RDF+XML collection
  # @note No tests for this method, as it is implemented by the RDF gem.
  # @example Save an array of documents in RDF+XML format to stdout
  #   doc_array = Document.find_all_by_solr_query(...)
  #   $stdout.write(doc_array.to_rdf_xml)
  # :nocov:
  def to_rdf_xml
    self.each do |x|
      raise ArgumentError, 'No to_rdf method for array element' unless x.respond_to? :to_rdf
    end

    ::RDF::Writer.for(:rdf).buffer do |writer|
      self.each do |x|
        writer << x.to_rdf
      end
    end
  end
  # :nocov:
end
