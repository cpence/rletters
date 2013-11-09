# -*- encoding : utf-8 -*-

module Serializers

  # Convert a document to an OpenURL query
  module OpenURL
    # Returns the URL parameters for an OpenURL query for this document
    #
    # @api public
    # @return [String] article as OpenURL parameters
    # @example Get a link to the given document in WorldCat
    #   "http://worldcatlibraries.org/registry/gateway?" +
    #     @document.to_openurl_params
    def to_openurl_params
      params = 'ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.genre=article'
      params << "&rft_id=info:doi%2F#{CGI.escape(doi)}" if doi.present?
      params << "&rft.atitle=#{CGI.escape(title)}" if title.present?
      params << "&rft.title=#{CGI.escape(journal)}" if journal.present?
      params << "&rft.date=#{CGI.escape(year)}" if year.present?
      params << "&rft.volume=#{CGI.escape(volume)}" if volume.present?
      params << "&rft.issue=#{CGI.escape(number)}" if number.present?
      params << "&rft.spage=#{CGI.escape(start_page)}" if start_page.present?
      params << "&rft.epage=#{CGI.escape(end_page)}" if end_page.present?
      if formatted_author_list.present?
        au = formatted_author_list[0]
        params << "&rft.aufirst=#{CGI.escape(au.first)}" if au.first.present?
        params << "&rft.aulast=#{CGI.escape(au.last)}" if au.last.present?
      end
      if author_list.present? && author_list.count > 1
        author_list[1...author_list.size].each do |a|
          params << "&rft.au=#{CGI.escape(a)}"
        end
      end
      params
    end
  end
end
