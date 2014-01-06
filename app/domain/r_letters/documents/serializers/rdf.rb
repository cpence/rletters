# -*- encoding : utf-8 -*-
require 'rdf/n3'

module RLetters
  module Documents
    module Serializers
      # Convert a document to an RDF record
      class RDF
        # Create a serializer
        #
        # @api public
        # @param document [Document] a document to serialize
        def initialize(document)
          unless document.is_a? Document
            fail ArgumentError, 'Cannot serialize a non-Document class'
          end
          @doc = document
        end

        # Return the user-friendly name of the serializer
        #
        # @return [String] name of the serializer
        def self.format
          'RDF::Graph'
        end

        # Return a URL where information about this serializer can be found
        #
        # @return [String] URL for information about this format
        def self.url
          'https://github.com/ruby-rdf/rdf'
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
        #     writer << RLetters::Documents::Serializers::RDF.new(doc)
        #   end
        def serialize
          graph = ::RDF::Graph.new
          doc = ::RDF::Node.new

          if @doc.formatted_author_list.present?
            @doc.formatted_author_list.each do |a|
              name = ''
              name << "#{a.von} " if a.von.present?
              name << "#{a.last}"
              name << " #{a.suffix}" if a.suffix.present?
              name << ", #{a.first}"
              graph << [doc, ::RDF::DC.creator, name]
            end
          end
          graph << [doc, ::RDF::DC.issued, @doc.year] if @doc.year.present?

          citation = "#{@doc.journal}" if @doc.journal.present?
          citation << (@doc.volume.present? ? " #{@doc.volume}" : ' ')
          citation << "(#{@doc.number})" if @doc.number.present?
          citation << ", #{@doc.pages}" if @doc.pages.present?
          citation << ". (#{@doc.year})" if @doc.year.present?
          graph << [doc, ::RDF::DC.bibliographicCitation, citation]

          ourl = ::RDF::Literal.new(
            '&' + RLetters::Documents::AsOpenURL.new(@doc).params,
            datatype: ::RDF::URI.new('info:ofi/fmt:kev:mtx:ctx')
          )
          graph << [doc, ::RDF::DC.bibliographicCitation, ourl]

          graph << [doc, ::RDF::DC.relation, @doc.journal] if @doc.journal.present?
          graph << [doc, ::RDF::DC.title, @doc.title] if @doc.title.present?
          graph << [doc, ::RDF::DC.type, 'Journal Article']
          graph << [doc, ::RDF::DC.identifier, "info:doi/#{@doc.doi}"] if @doc.doi.present?

          graph
        end
      end
    end
  end
end
