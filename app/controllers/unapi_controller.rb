# -*- encoding : utf-8 -*-

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
  # @api public
  # @return [undefined]
  def index
    unless params[:id].blank?
      unless params[:format].blank?
        format = params[:format].to_s.to_sym
        if Document.serializers.has_key? format
          redirect_to controller: 'search', action: 'show',
            id: params[:id], format: format
        else
          render template: 'errors/404', layout: false,
            formats: [ :html ], status: 406
        end
      else
        render template: 'unapi/formats', formats: [ :xml ],
          handlers: [ :builder ], layout: false, status: 300
      end
    else
      render template: 'unapi/formats', formats: [ :xml ],
        handlers: [ :builder ], layout: false
    end
  end
end
