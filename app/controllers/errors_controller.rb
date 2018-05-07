# frozen_string_literal: true

# Render server error pages
#
# We configure the error handling in Rails to redirect server errors to this
# controller rather than to the static HTML pages in the public directory,
# as we need to be able to render these using templates.
class ErrorsController < ApplicationController
  # Render a 404 error page
  #
  # @return [void]
  def not_found
    respond_to do |format|
      format.html do
        render(template: 'errors/404',
               layout: false,
               status: :not_found)
      end
      format.any { render(plain: '404 Not Found', status: :not_found) }
    end
  end

  # Render a 422 error page
  #
  # This isn't tested, as I can't figure out a way to programmatically generate
  # a 422 error in an integration test.
  #
  # @return [void]
  # :nocov:
  def unprocessable
    respond_to do |format|
      format.html do
        render(template: 'errors/422',
               layout: false,
               status: :unprocessable_entity)
      end
      format.any do
        render(plain: '422 Unprocessable Entity',
               status: :unprocessable_entity)
      end
    end
  end
  # :nocov:

  # Render a 500 error page
  #
  # @return [void]
  def internal_error
    render(template: 'errors/500', layout: false,
           formats: [:html], status: :internal_server_error)
  end
end
