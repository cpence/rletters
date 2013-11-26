# -*- encoding : utf-8 -*-

# Model containing all of our global settings
#
# This model (via the +druthers+ gem) is the single source for
# all of our global application settings (such as the URL for the Solr server,
# the site title, etc.).
#
# @example Get the Solr URL
#   Admin::Setting.solr_server_url
#   # => 'http://localhost:8983/solr/'
class Admin::Setting < ActiveRecord::Base
  self.table_name = 'admin_settings'
  serialize :value

  # The list of setting keys that can be used
  VALID_KEYS = [:app_name, :app_email, :app_domain, :solr_server_url,
                :solr_timeout, :mendeley_key, :airbrake_key,
                :google_analytics_key, :secret_token, :secret_key_base,
                :devise_secret_key]

  # The list of keys that shouldn't be edited by the user in the admin panel
  HIDDEN_KEYS = [:secret_token, :secret_key_base, :devise_secret_key]

  # The list of setting keys that can be used
  #
  # @api public
  # @return [Array<Symbol>] valid setting keys
  def self.valid_keys
    VALID_KEYS
  end

  # The list of setting keys that shouldn't be shown in the admin interface
  #
  # @api public
  # @return [Array<Symbol>] hidden setting keys
  def self.hidden_keys
    HIDDEN_KEYS
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
