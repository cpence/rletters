
# Display static pages and images
#
# There are a number of pages in RLetters that do not change with time, as well
# as images that need to be shown throughout the site. This controller is the
# thin support for those tasks.
class StaticController < ApplicationController
  layout 'full_page'

  # Return one of the uploaded-asset images
  #
  # @return [void]
  def image
    model = Admin::UploadedAsset.find(params[:id])
    send_data Paperclip.io_adapters.for(model.file).read,
              filename: model.file_file_name,
              content_type: model.file_content_type
  end

  # Show the cookie information page
  #
  # @return [void]
  def cookies
    @page = :cookies
    render :page
  end
end
