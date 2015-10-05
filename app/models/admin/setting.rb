
# Code for objects pertaining to administration
module Admin
  # Model containing all of our global settings
  #
  # This model (via the `druthers` gem) is the single source for
  # all of our global application settings (such as the URL for the Solr server,
  # the site title, etc.).
  class Setting < ActiveRecord::Base
    self.table_name = 'admin_settings'
    serialize :value

    # The list of setting keys that can be used
    VALID_KEYS = [:secret_token, :secret_key_base, :devise_secret_key]

    # The list of keys that shouldn't be edited by the user in the admin panel
    HIDDEN_KEYS = [:secret_token, :secret_key_base, :devise_secret_key]

    # The list of setting keys that can be used
    #
    # @return [Array<Symbol>] valid setting keys
    def self.valid_keys
      VALID_KEYS
    end

    # The list of setting keys that shouldn't be shown in the admin interface
    #
    # @return [Array<Symbol>] hidden setting keys
    def self.hidden_keys
      HIDDEN_KEYS
    end

    def_druthers(*VALID_KEYS)

    # @return [String] Friendly name of this setting (looked up in locale)
    def friendly_name
      ret = I18n.t("settings.#{key}", default: '')
      return key.to_s if ret == ''
      ret
    end
  end
end
