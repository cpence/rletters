# -*- encoding : utf-8 -*-

module RLetters
  module Documents
    # Serialization code for +Document+ objects
    #
    # This module contains helpers intended to be included by the +Document+
    # model, which allow the document to be converted to any one of a number of
    # export formats.
    module Serializers
      # Convert a document to a BibTeX record
      class BibTex
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
          'BibTeX'
        end

        # Return a URL where information about this serializer can be found
        #
        # @return [String] URL for information about this format
        def self.url
          'http://mirrors.ctan.org/biblio/bibtex/contrib/doc/btxdoc.pdf'
        end

        # Returns this document as a BibTeX record
        #
        # @api public
        # @return [String] document in BibTeX format
        # @example Download this document as a enw file
        #   controller.send_data(
        #     RLetters::Documents::Serializers::BibTex.new(doc).serialize,
        #     filename: 'export.bib', disposition: 'attachment'
        #   )
        def serialize
          if @doc.is_a? Document
            do_serialize(@doc)
          else
            @doc.map { |d| do_serialize(d) }.join
          end
        end

        private

        # :nodoc:
        def do_serialize(doc)
          # We don't have a concept of cite keys, so we're forced to just use
          # AuthorYear and hope it doesn't collide
          if doc.formatted_author_list.empty?
            first_author = 'Anon'
          else
            first_author = doc.formatted_author_list[0].last.gsub(' ', '').gsub(/[^A-za-z0-9_]/, '')
          end
          cite_key = "#{first_author}#{doc.year}"

          ret  = "@article{#{cite_key},\n"
          ret << "    author = {#{doc.author_list.join(' and ')}},\n" unless doc.author_list.empty?
          ret << "    title = {#{doc.title}},\n" if doc.title
          ret << "    journal = {#{doc.journal}},\n" if doc.journal
          ret << "    volume = {#{doc.volume}},\n" if doc.volume
          ret << "    number = {#{doc.number}},\n" if doc.number
          ret << "    pages = {#{doc.pages}},\n" if doc.pages
          ret << "    doi = {#{doc.doi}},\n" if doc.doi
          ret << "    year = {#{doc.year}}\n" if doc.year
          ret << "}\n"

          ret
        end
      end
    end
  end
end
