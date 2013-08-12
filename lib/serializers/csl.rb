# -*- encoding : utf-8 -*-
require 'citeproc'

# Serialization code for +Document+ objects
#
# This module contains helpers intended to be included by the +Document+
# model, which allow the document to be converted to any one of a number of
# export formats.
module Serializers

  # Serialization code to Citation Style Language
  #
  # The Citation Style Language (http://citationstyles.org) is a language
  # designed for the processing of citations and bibliographic entries. In
  # RLetters, we use CSL to allow users to format the list of search results
  # in whatever bibliography-entry format they choose.
  module CSL
    # Returns a hash representing the article in CSL format
    #
    # @api public
    # @return [Hash] article as a CSL record
    # @example Get the CSL entry for a given document
    #   doc = Document.new(...)
    #   doc.to_csl
    #   # => { 'type' => 'article-journal', 'author' => ... }
    def to_csl
      ret = {}
      ret['type'] = 'article-journal'

      if formatted_author_list && formatted_author_list.count
        ret['author'] = formatted_author_list.map { |a| a.to_citeproc }
      end

      ret['title'] = title unless title.blank?
      ret['container-title'] = journal unless journal.blank?
      ret['issued'] = { 'date-parts' => [[Integer(year)]] } unless year.blank?
      ret['volume'] = volume unless volume.blank?
      ret['issue'] = number unless number.blank?
      ret['page'] = pages unless pages.blank?

      ret
    end

    # Convert the document to CSL, and format it with the given style
    #
    # Takes a document and converts it to a bibliographic entry in the
    # specified style using CSL.
    #
    # @api public
    # @param [String] style_or_url CSL style to use (a CslStyle or URL)
    # @return [String] bibliographic entry in the given style
    # @example Convert a given document to Chicago author-date format
    #   doc.to_csl_entry(csl_style)
    #   # => "Doe, John. 2000. ..."
    def to_csl_entry(style_or_url)
      if style_or_url.is_a? CslStyle
        # Get the XML style
        style = style_or_url.style
      elsif style_or_url.is_a? String
        style = style_or_url
      else
        fail ArgumentError, 'Argument must be CslStyle or String'
      end

      CiteProc.process(to_csl, format: :html, style: style).strip.html_safe
    end
  end
end
