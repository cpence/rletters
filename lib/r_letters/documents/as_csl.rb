# -*- encoding : utf-8 -*-
require 'citeproc'

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
      def hash
        ret = {}
        ret['type'] = 'article-journal'

        unless @doc.formatted_author_list.empty?
          ret['author'] = @doc.formatted_author_list.map { |a| a.to_citeproc }
        end

        ret['title'] = @doc.title if @doc.title
        ret['container-title'] = @doc.journal if @doc.journal
        ret['issued'] = { 'date-parts' => [[Integer(@doc.year)]] } if @doc.year
        ret['volume'] = @doc.volume if @doc.volume
        ret['issue'] = @doc.number if @doc.number
        ret['page'] = @doc.pages if @doc.pages

        ret
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
        CiteProc.process(hash, format: :html, style: style.style).strip
      end
    end
  end
end
