# frozen_string_literal: true

# Display static pages and images
#
# There are a number of pages in RLetters that do not change with time, as well
# as images that need to be shown throughout the site. This controller is the
# thin support for those tasks.
class StaticController < ApplicationController
  layout 'full_page'

  # Show a variety of static information pages
  #
  # @return [void]
  %i[cookies user_data].each do |page|
    define_method page do
      @page = page
      render :page
    end
  end

  # Return the form posted to this URL as a download
  #
  # This is used to facilitate downloads of SVG files from D3.js, among other
  # uses.
  #
  # @return [void]
  def echo
    params.require([:data, :content_type, :filename])

    send_data(params[:data], filename: params[:filename],
                             type: params[:content_type])
  end
end
