# -*- encoding : utf-8 -*-

# Display the user's workflow through RLetters
#
# We walk the user through the process of logging in, selecting an analysis
# type to run, gathering datasets, and collecting results.  This controller
# is responsible for all of that.
class WorkflowController < ApplicationController
  layout 'full_page'

  # Show the introduction page or the user dashboard
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

    if current_user
      render 'dashboard'
    else
      render 'index'
    end
  end

  # Start running a new analysis
  #
  # @api public
  # @return [undefined]
  def start
  end

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
