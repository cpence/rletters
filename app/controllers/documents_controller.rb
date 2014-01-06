# -*- encoding : utf-8 -*-

# Interact with individual documents
#
# This controller allows users to interact directly with single documents,
# including adding them to datasets, exporting them in different formats, and
# visiting them on external services.
class DocumentsController < ApplicationController
  # Export an individual document
  #
  # This action is content-negotiated: you must request the page for a document
  # with one of the MIME types specified in +Document.serializers+, and you
  # will get a citation export back, as a download.
  #
  # @api public
  # @return [undefined]
  def export
    @document = Document.find(params[:uid])

    respond_to do |format|
      format.any(*Document.serializers.keys.map { |k| k.to_sym }) do
        f = Document.serializers[request.format.to_sym.to_s]

        headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
        headers['Expires'] = '0'
        send_data(f[:method].call(@document),
                  filename: "export.#{request.format.to_sym}",
                  type: request.format.to_s,
                  disposition: 'attachment')
        return
      end
      format.any do
        render template: 'errors/404',
               layout: false,
               formats: [:html],
               status: 406
        return
      end
    end
  end

  # Redirect to the Mendeley page for a document
  # @api public
  # @return [undefined]
  def mendeley
    fail ActiveRecord::RecordNotFound if Admin::Setting.mendeley_key.blank?

    @document = Document.find(params[:uid])

    begin
      res = Net::HTTP.start('api.mendeley.com') do |http|
        http.get("/oapi/documents/search/title%3A#{CGI.escape(@document.title)}/?consumer_key=#{Admin::Setting.mendeley_key}")
      end
      json = res.body
      result = JSON.parse(json)

      mendeley_docs = result['documents']
      fail ActiveRecord::RecordNotFound unless mendeley_docs.size

      redirect_to mendeley_docs[0]['mendeley_url']
    rescue *Net::HTTP::EXCEPTIONS
      raise ActiveRecord::RecordNotFound
    end
  end

  # Redirect to the Citeulike page for a document
  # @api public
  # @return [undefined]
  def citeulike
    @document = Document.find(params[:uid])

    begin
      res = Net::HTTP.start('www.citeulike.org') do |http|
        http.get("/json/search/all?per_page=1&page=1&q=title%3A%28#{CGI.escape(@document.title)}%29")
      end
      json = res.body
      cul_docs = JSON.parse(json)

      fail ActiveRecord::RecordNotFound unless cul_docs.size

      redirect_to cul_docs[0]['href']
    rescue *Net::HTTP::EXCEPTIONS
      raise ActiveRecord::RecordNotFound
    end
  end
end
