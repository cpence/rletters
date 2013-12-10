# -*- encoding : utf-8 -*-
require 'addressable/uri'

# Validate a URL, using addressable.
#
# Thanks to Eric Himmelreich for this snippet.
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    uri = Addressable::URI.parse(value)
    fail Addressable::URI::InvalidURIError unless uri

    unless %w(http https ftp).include?(uri.scheme)
      fail Addressable::URI::InvalidURIError
    end
  rescue Addressable::URI::InvalidURIError
    # FIXME: Where do I put the localization for this?
    record.errors[attribute] << 'is an invalid URL'
  end
end
