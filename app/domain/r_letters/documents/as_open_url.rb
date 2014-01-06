# -*- encoding : utf-8 -*-

module RLetters
  module Documents
    # Convert a document to an OpenURL query
    class AsOpenURL
      # Initialize an OpenURL converter
      #
      # @param document [Document] the document to convert
      def initialize(document)
        unless document.is_a? Document
          fail ArgumentError, 'Cannot convert a non-Document class to OpenURL'
        end
        @doc = document
      end

      # Returns the URL parameters for an OpenURL query for this document
      #
      # @api public
      # @return [String] article as OpenURL parameters
      # @example Get a link to the given document in WorldCat
      #   "http://worldcatlibraries.org/registry/gateway?" +
      #     RLetters::Documents::AsOpenUrl.new(@document).params
      def params
        params = 'ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.genre=article'
        params << "&rft_id=info:doi%2F#{CGI.escape(@doc.doi)}" if @doc.doi.present?
        params << "&rft.atitle=#{CGI.escape(@doc.title)}" if @doc.title.present?
        params << "&rft.title=#{CGI.escape(@doc.journal)}" if @doc.journal.present?
        params << "&rft.date=#{CGI.escape(@doc.year)}" if @doc.year.present?
        params << "&rft.volume=#{CGI.escape(@doc.volume)}" if @doc.volume.present?
        params << "&rft.issue=#{CGI.escape(@doc.number)}" if @doc.number.present?
        params << "&rft.spage=#{CGI.escape(@doc.start_page)}" if @doc.start_page.present?
        params << "&rft.epage=#{CGI.escape(@doc.end_page)}" if @doc.end_page.present?
        if @doc.formatted_author_list.present?
          au = @doc.formatted_author_list[0]
          params << "&rft.aufirst=#{CGI.escape(au.first)}" if au.first.present?
          params << "&rft.aulast=#{CGI.escape(au.last)}" if au.last.present?
        end
        if @doc.author_list.present? && @doc.author_list.count > 1
          @doc.author_list[1...@doc.author_list.size].each do |a|
            params << "&rft.au=#{CGI.escape(a)}"
          end
        end
        params
      end
    end
  end
end
