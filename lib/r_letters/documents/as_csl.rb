# -*- encoding : utf-8 -*-
require 'citeproc'
require 'csl/styles'

module RLetters
  module Documents
    # Conversion code to Citation Style Language
    #
    # The Citation Style Language (http://citationstyles.org) is a language
    # designed for the processing of citations and bibliographic entries. In
    # RLetters, we use CSL to allow users to format the list of search results
    # in whatever bibliography-entry format they choose.
    class AsCSL
      # Initialize a CSL converter
      #
      # @param document [Document] the document to convert
      def initialize(document)
        @doc = document
      end

      # Returns a hash representing the article in CSL format
      #
      # @api public
      # @return [Hash] article as a CSL record
      # @example Get the CSL entry for a given document
      #   doc = Document.new(...)
      #   RLetters::Documents::AsCSL.new(doc).hash
      #   # => { 'type' => 'article-journal', 'author' => ... }
      def citeproc_item
        item = CiteProc::Item.new(id: @doc.uid, type: 'article-journal')

        unless @doc.authors.empty?
          item.author = CiteProc::Names.new
          @doc.authors.each do |a|
            item.author << CiteProc::Name.new(a.to_citeproc)
          end
        end

        item.title = @doc.title if @doc.title
        item.container_title = @doc.journal if @doc.journal
        item.issued = CiteProc::Date.new(Integer(@doc.year)) if @doc.year
        item.volume = @doc.volume if @doc.volume
        item.issue = @doc.number if @doc.number
        item.page = @doc.pages if @doc.pages

        item
      end

      # Convert the document to CSL, and format it with the given style
      #
      # Takes a document and converts it to a bibliographic entry in the
      # specified style using CSL.
      #
      # @api public
      # @param [CslStyle] style CSL style to use
      # @return [String] bibliographic entry in the given style
      # @example Convert a given document to Chicago author-date format
      #   RLetters::Documents::AsCSL.new(doc).entry(csl_style)
      #   # => "Doe, John. 2000. ..."
      def entry(style)
        processor = CiteProc::Processor.new(style: style.style, format: 'html')
        item = citeproc_item

        processor.register(citeproc_item)
        processor.render(:bibliography, id: @doc.uid)[0]
      end
    end
  end
end
