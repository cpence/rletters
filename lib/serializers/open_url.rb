# -*- encoding : utf-8 -*-

module Serializers
  
  # Convert a document to an OpenURL query
  module OpenURL
    # Returns the URL parameters for an OpenURL query for this document
    #
    # @api public
    # @return [String] article as OpenURL parameters
    # @example Get a link to the given document in WorldCat
    #   "http://worldcatlibraries.org/registry/gateway?#{@document.to_openurl_params}"
    def to_openurl_params
      params = "ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.genre=article"
      params << "&rft_id=info:doi%2F#{CGI::escape(doi)}" unless doi.blank?
      params << "&rft.atitle=#{CGI::escape(title)}" unless title.blank?
      params << "&rft.title=#{CGI::escape(journal)}" unless journal.blank?
      params << "&rft.date=#{CGI::escape(year)}" unless year.blank?
      params << "&rft.volume=#{CGI::escape(volume)}" unless volume.blank?
      params << "&rft.issue=#{CGI::escape(number)}" unless number.blank?
      params << "&rft.spage=#{CGI::escape(start_page)}" unless start_page.blank?
      params << "&rft.epage=#{CGI::escape(end_page)}" unless end_page.blank?
      unless formatted_author_list.nil? || formatted_author_list.count == 0
        au = formatted_author_list[0]
        params << "&rft.aufirst=#{CGI::escape(au.first)}" unless au.first.blank?
        params << "&rft.aulast=#{CGI::escape(au.last)}" unless au.last.blank?
      end
      unless author_list.nil? || author_list.count <= 1
        author_list[1...author_list.size].each do |a|
          params << "&rft.au=#{CGI::escape(a)}"
        end
      end
      params
    end
  end
end
