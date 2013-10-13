# -*- encoding : utf-8 -*-

# Model containing all of our global settings
#
# This model (via the +druthers+ gem) is the single source for
# all of our global application settings (such as the URL for the Solr server,
# the site title, etc.).
#
# @example Get the Solr URL
#   Setting.solr_server_url
#   # => 'http://localhost:8983/solr/'
class Setting < ActiveRecord::Base
  serialize :value

  # The list of setting keys that can be used
  VALID_KEYS = [:app_name, :app_email, :app_domain, :solr_server_url,
    :solr_timeout, :mendeley_key, :airbrake_key, :google_analytics_key,
    :secret_token, :secret_key_base, :devise_secret_key]

  # The list of setting keys that can be used
  #
  # @api public
  # @return [Array<String>] valid setting keys
  def self.valid_keys
    VALID_KEYS
  end

  def_druthers(*VALID_KEYS)

  def self.default_app_name
    'RLetters'
  end
  def self.default_app_email
    'not@an.email.com'
  end
  def self.default_app_domain
    'not.a.web.site.com'
  end
  def self.default_solr_server_url
    'http://localhost:8983/'
  end
  def self.default_solr_timeout
    120
  end

  # @return [String] Friendly name of this asset (looked up in locale)
  def friendly_name
    ret = I18n.t("settings.#{key}", default: '')
    return key.to_s if ret == ''
    ret
  end
end
