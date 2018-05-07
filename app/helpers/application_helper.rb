# frozen_string_literal: true

module ApplicationHelper
  # Return the validation errors for a field on a particular object
  #
  # These will be concatenated and separated by <br> tags, for display in the
  # Bootstrap 4 invalid-feedback field.
  #
  # @param [Object] object the object to check for errors on (or symbol
  #   denoting class name)
  # @param [Symbol] field the field to check for errors on
  # @param [Boolean] client_side if true, we are performing client-side
  #   validation on this field, so even if there are no server-side validation
  #   failures, we will add a 'blank' error message for this field
  # @param [String] client_side_message if set, override our default message
  #   lookup for the 'blank' error message to the given translation key
  # @return [String] the contents of the invalid-feedback div
  def validation_errors_for(object, field, client_side = false,
                            client_side_message = nil)
    ret = []

    if !object.is_a?(Symbol) && object.errors[field]
      server_errors = content_tag(:span, class: 'server-errors') do
        safe_join(object.errors[field], tag(:br))
      end

      ret << server_errors
    end

    if client_side
      if client_side_message
        key = client_side_message
      else
        klass = if object.is_a?(Symbol)
                  object
                else
                  object.model_name.i18n_key
                end
        key = "activerecord.errors.models.#{klass}.#{field}.blank"
      end

      # If we have a server-side error message to show (on initial load), then
      # start the client-side error message as hidden, and show it when we do
      # the actual JS client-side validation.
      client_error = content_tag(
        :span,
        class: 'client-errors',
        style: if !object.is_a?(Symbol) && object.errors[field]
                 'display: none'
               else
                 nil
               end) do
        I18n.t(key)
      end

      ret << client_error
    end

    safe_join(ret)
  end

  # Standard markup for a close icon
  #
  # @param [Hash] data if set, data attributes for the tag
  # @return [String] the close icon
  def close_icon(data = nil)
    attributes = {
      class: 'close',
      type: 'button',
      'aria-label': I18n.t('common.close')
    }
    data&.each { |k, v| attributes["data-#{k}"] = v }

    content_tag(:button, attributes) do
      content_tag(:i, '', class: 'fa fa-window-close')
    end
  end
end
