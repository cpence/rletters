# frozen_string_literal: true

module RLetters
  module Documents
    module Serializers
      # Convert a document to a BibTeX record
      class BibTex < Base
        define_array(:bibtex, 'BibTeX',
                     'http://mirrors.ctan.org/biblio/bibtex/contrib/doc/btxdoc.pdf') do |doc|
          # We don't have a concept of cite keys, so we're forced to just use
          # AuthorYear and hope it doesn't collide
          first_author =
            if doc.authors.empty?
              'Anon'
            else
              doc.authors[0].last.delete(' ').gsub(/[^A-za-z0-9_]/, '')
            end
          cite_key = "#{first_author}#{doc.year}"

          ret = +"@article{#{cite_key},\n"
          ret << "    author = {#{doc.authors.map(&:full).join(' and ')}},\n" unless doc.authors.empty?
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
