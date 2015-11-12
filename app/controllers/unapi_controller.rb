
# Access bibliographic data using unAPI
#
# This controller enables access to citation data for individual document
# records using the unAPI interface, used most prominently by Zotero (as well
# as other web-based bibliography managers).
class UnapiController < ApplicationController
  # Implement all of unAPI
  #
  # If an id is set, return either a list of formats customized for a
  # particular document.  If an id and a format are both set,
  # return the actual document (or a 406 error).  If an id is not set,
  # then show the list of all possible export formats.
  #
  # The best way to understand how this API works is to check out the
  # RSpec tests for this controller, which implement a full unAPI validation
  # suite.
  #
  # @return [void]
  def index
    if params[:id].blank?
      render template: 'unapi/formats',
             formats: [:xml],
             handlers: [:builder],
             layout: false
      return
    end

    if params[:format].blank?
      render template: 'unapi/formats',
             formats: [:xml],
             handlers: [:builder],
             layout: false,
             status: 300
      return
    end

    format = params[:format]
    if RLetters::Documents::Serializers::Base.available.include? format.to_sym
      redirect_to documents_export_path(params[:id], format: format)
    else
      render template: 'errors/404',
             layout: false,
             formats: [:html],
             status: 406
    end
  end
end
