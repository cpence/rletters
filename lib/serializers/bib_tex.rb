# -*- encoding : utf-8 -*-

module Serializers

  # Convert a document to a BibTeX record
  module BibTex

    # Register this serializer in the Document list
    def self.included(base)
      base.register_serializer(
        :bibtex,
        'BibTeX', ->(doc) { doc.to_bibtex },
        'http://mirrors.ctan.org/biblio/bibtex/contrib/doc/btxdoc.pdf'
      )
    end

    # Returns this document as a BibTeX record
    #
    # @api public
    # @return [String] document in BibTeX format
    # @example Download this document as a bib file
    #   controller.send_data doc.to_bibtex, filename: 'export.bib',
    #                        disposition: 'attachment'
    def to_bibtex
      # We don't have a concept of cite keys, so we're forced to just use
      # AuthorYear and hope it doesn't collide
      if formatted_author_list.nil? || formatted_author_list.count == 0
        first_author = 'Anon'
      else
        first_author = formatted_author_list[0].last.gsub(' ', '').gsub(/[^A-za-z0-9_]/, '')
      end
      cite_key = "#{first_author}#{year}"

      ret  = "@article{#{cite_key},\n"
      unless author_list.nil? || author_list.count == 0
        ret << "    author = {#{author_list.join(' and ')}},\n"
      end
      ret << "    title = {#{title}},\n" unless title.blank?
      ret << "    journal = {#{journal}},\n" unless journal.blank?
      ret << "    volume = {#{volume}},\n" unless volume.blank?
      ret << "    number = {#{number}},\n" unless number.blank?
      ret << "    pages = {#{pages}},\n" unless pages.blank?
      ret << "    doi = {#{doi}},\n" unless doi.blank?
      ret << "    year = {#{year}}\n" unless year.blank?
      ret << "}\n"

      ret
    end
  end
end

# Ruby's standard Array class
class Array
  # Convert this array (of Document objects) to a BibTeX collection
  #
  # Only will work on arrays that consist entirely of Document objects, will
  # raise an ArgumentError otherwise.
  #
  # @api public
  # @return [String] array of documents as BibTeX collection
  # @example Save an array of documents in BibTeX format to stdout
  #   doc_array = Solr::Connection.find(...).documents
  #   $stdout.write(doc_array.to_bibtex)
  def to_bibtex
    each do |x|
      raise ArgumentError, 'No to_bibtex method for array element' unless x.respond_to? :to_bibtex
    end

    map { |x| x.to_bibtex }.join
  end
end
