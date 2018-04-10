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
    ret = ''

    if !object.is_a?(Symbol) && object.errors[field]
      server_errors = '<span class="server-errors">'
      server_errors << object.errors[field].map { |e| sanitize(e) }.join('<br>')
      server_errors << '</span>'

      ret << server_errors
    end

    if client_side
      if client_side_message
        key = client_side_message
      else
        if object.is_a?(Symbol)
          klass = object
        else
          klass = object.model_name.i18n_key
        end
        key = "activerecord.errors.models.#{klass}.#{field}.blank"
      end

      # If we have a server-side error message to show (on initial load), then
      # start the client-side error message as hidden, and show it when we do
      # the actual JS client-side validation.
      if !object.is_a?(Symbol) && object.errors[field]
        client_error = '<span class="client-errors" style="display:none">'
      else
        client_error = '<span class="client-errors">'
      end
      client_error << I18n.t(key)
      client_error << '</span>'

      ret << client_error
    end

    ret.html_safe
  end

  # Standard markup for a close icon
  #
  # @param [Hash] data if set, data attributes for the tag
  # @return [String] the close icon
  def close_icon(data = nil)
    ret = '<button class="close" type="button" aria-label="close"'
    if data
      data.each do |k, v|
        ret << " data-#{k}='#{v}'"
      end
    end
    ret << '><i class="fa fa-window-close"></i></button>'
    ret.html_safe
  end
end
