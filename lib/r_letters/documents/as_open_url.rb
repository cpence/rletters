# frozen_string_literal: true

module RLetters
  module Documents
    # Convert a document to an OpenURL query
    class AsOpenURL
      # Initialize an OpenURL converter
      #
      # @param document [Document] the document to convert
      def initialize(document)
        @doc = document
      end

      # Returns the URL parameters for an OpenURL query for this document
      #
      # @return [String] article as OpenURL parameters
      def params
        params = 'ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.genre=article'.dup
        params << "&rft_id=info:doi%2F#{CGI.escape(@doc.doi)}" if @doc.doi
        params << "&rft.atitle=#{CGI.escape(@doc.title)}" if @doc.title
        params << "&rft.title=#{CGI.escape(@doc.journal)}" if @doc.journal
        params << "&rft.date=#{CGI.escape(@doc.year)}" if @doc.year
        params << "&rft.volume=#{CGI.escape(@doc.volume)}" if @doc.volume
        params << "&rft.issue=#{CGI.escape(@doc.number)}" if @doc.number
        params << "&rft.spage=#{CGI.escape(@doc.start_page)}" if @doc.start_page
        params << "&rft.epage=#{CGI.escape(@doc.end_page)}" if @doc.end_page
        unless @doc.authors.empty?
          au = @doc.authors[0]
          params << "&rft.aufirst=#{CGI.escape(au.first)}" if au.first
          params << "&rft.aulast=#{CGI.escape(au.last)}" if au.last
        end
        if @doc.authors.size > 1
          @doc.authors[1...@doc.authors.size].each do |a|
            params << "&rft.au=#{CGI.escape(a.full)}"
          end
        end
        params
      end
    end
  end
end
