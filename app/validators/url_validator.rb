# -*- encoding : utf-8 -*-

# Validate a URL, using addressable.
#
# Thanks to Eric Himmelreich for this snippet.
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    uri = Addressable::URI.parse(value)
    raise Addressable::URI::InvalidURIError unless uri

    unless %w(http https ftp).include?(uri.scheme)
      raise Addressable::URI::InvalidURIError
    end
  rescue Addressable::URI::InvalidURIError
    # FIXME: Where do I put the localization for this?
    record.errors[attribute] << 'is an invalid URL'
  end
end
