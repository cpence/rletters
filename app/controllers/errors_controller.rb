# -*- encoding : utf-8 -*-

# Render server error pages
#
# We configure the error handling in Rails to redirect server errors to this
# controller rather than to the static HTML pages in the public directory,
# as we need to be able to render these using templates.
class ErrorsController < ApplicationController
  # Render a 404 error page
  #
  # @api public
  # @return [undefined]
  def not_found
    render :template => 'errors/404', :layout => false
  end

  # Render a 422 error page
  #
  # @api public
  # @return [undefined]
  def unprocessable
    render :template => 'errors/422', :layout => false
  end

  # Render a 500 error page
  #
  # @api public
  # @return [undefined]
  def internal_error
    render :template => 'errors/500', :layout => false
  end
end
