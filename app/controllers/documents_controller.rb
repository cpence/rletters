# frozen_string_literal: true

# Interact with individual documents
#
# This controller allows users to interact directly with single documents,
# including adding them to datasets, exporting them in different formats, and
# visiting them on external services.
class DocumentsController < ApplicationController
  # Export an individual document
  #
  # This action is content-negotiated: you must request the page for a document
  # with one of the MIME types we can export, and you will get a citation
  # export back, as a download.
  #
  # @return [void]
  def export
    @document = Document.find(params[:uid])

    respond_to do |format|
      format.any(*RLetters::Documents::Serializers::Base.available) do
        klass = RLetters::Documents::Serializers::Base.for(request.format)

        headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
        headers['Expires'] = '0'
        send_data(klass.new(@document).serialize,
                  filename: "export.#{request.format.to_sym}",
                  type: request.format.to_s,
                  disposition: 'attachment')
        return
      end
      format.any do
        render file: error_page_path,
               formats: [:html],
               status: :not_acceptable
        return
      end
    end
  end

  # Redirect to the Citeulike page for a document
  #
  # @return [void]
  def citeulike
    @document = Document.find(params[:uid])

    begin
      res = Net::HTTP.start('www.citeulike.org') do |http|
        http.get("/json/search/all?per_page=1&page=1&q=title%3A%28#{CGI.escape(@document.title)}%29")
      end
      json = res.body
      cul_docs = JSON.parse(json)

      unless !cul_docs&.empty? && cul_docs&.first
        raise ActiveRecord::RecordNotFound
      end

      # We know that we're going to an external website here (that's the point)
      redirect_to cul_docs[0]['href'], allow_other_host: true
    rescue *Net::HTTP::EXCEPTIONS
      raise ActiveRecord::RecordNotFound
    end
  end
end
