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

  # The internal error pages that we render
  INTERNAL_ERRORS = %i[
    bad_request internal_server_error unprocessable_entity
  ].freeze

  # Render a number of internal error pages with the same template
  #
  # @return [void]
  # :nocov:
  INTERNAL_ERRORS.each do |sym|
    define_method sym do
      respond_to do |format|
        format.html do
          render(template: 'errors/500', layout: false, formats: [:html],
                 status: sym)
        end
        format.any do
          code = Rack::Utils::SYMBOL_TO_STATUS_CODE[sym]
          string = Rack::Utils::HTTP_STATUS_CODES[code]
          render(plain: "#{code} #{string}", status: sym)
        end
      end
    end
  end
  # :nocov:
end
