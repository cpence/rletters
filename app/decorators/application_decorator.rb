# -*- encoding : utf-8 -*-

# Base class for all decorators
#
# This class adds helper methods for Bootstrap content generation to all of
# the decorators in the app.
class ApplicationDecorator < Draper::Decorator
  protected

  # Render the Bootstrap close icon
  def close_icon
    '&nbsp;&nbsp;'.html_safe +
    h.content_tag(:button, class: 'close') do
      h.content_tag(:span, '&times;'.html_safe, 'aria-hidden' => 'true') +
      h.content_tag(:span, 'Close', class: 'sr-only')
    end
  end
end
