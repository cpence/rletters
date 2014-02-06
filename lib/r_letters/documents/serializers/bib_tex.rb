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
          @doc = document_or_array
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
          if @doc.is_a? Enumerable
            @doc.map { |d| do_serialize(d) }.join
          else
            do_serialize(@doc)
          end
        end

        private

        # :nodoc:
        def do_serialize(doc)
          # We don't have a concept of cite keys, so we're forced to just use
          # AuthorYear and hope it doesn't collide
          if doc.authors.empty?
            first_author = 'Anon'
          else
            first_author = doc.authors[0].last.gsub(' ', '').gsub(/[^A-za-z0-9_]/, '')
          end
          cite_key = "#{first_author}#{doc.year}"

          ret  = "@article{#{cite_key},\n"
          ret << "    author = {#{doc.authors.map { |a| a.full }.join(' and ')}},\n" unless doc.authors.empty?
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
