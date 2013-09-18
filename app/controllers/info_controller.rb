# -*- encoding : utf-8 -*-

# Display static information pages about RLetters
#
# This controller displays static information, such as the RLetters help, FAQ,
# and privacy policy.
class InfoController < ApplicationController

  # Query some Solr parameters for the index page
  #
  # This action will query the Solr database to get some nice statistics
  # for our index page.
  #
  # @api public
  # @return [undefined]
  def index
    solr_query = { q: '*:*',
                   defType: 'lucene',
                   rows: 1,
                   start: 0 }
    begin
      search_result = Solr::Connection.search solr_query
      @database_size = search_result.num_hits
    rescue StandardError
      @database_size = 0
    end
  end

  # Show the about page
  #
  # @api public
  # @return [undefined]
  def about; end

  # Show the FAQ
  #
  # @api public
  # @return [undefined]
  def faq; end

  # Show the privacy policy
  #
  # @api public
  # @return [undefined]
  def privacy; end

  # Show the tutorial
  #
  # @api public
  # @return [undefined]
  def tutorial; end

  # Return one of the uploaded-asset images
  #
  # @api public
  # @return [undefined]
  def image
    model = UploadedAsset.find(params[:id])
    style = params[:style] ? params[:style] : 'original'
    send_data model.file.file_contents(style),
              filename: model.file_file_name,
              content_type: model.file_content_type
  end
end
