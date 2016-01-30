
module Admin
  # A class to encapsulate feature flag behavior
  #
  # We want to be able to activate and deactivate portions of the application
  # on the fly, and this class allows us to do that in the database.
  #
  # @!attribute maintenance_message
  #   @return [String] if set, display this message as a permanent flash
  #     at the top of all site pages
  class FeatureFlags < Setler::Settings
    self.table_name = 'admin_feature_flags'

    # All of the feature flags available in the application, with
    # simple_form types. Make sure when adding a feature flag here to add
    # a default value for it in the appropriate initializer.
    ALL_FEATURES = [
      { var: :maintenance_message, type: :string }
    ]

    # @return (see ApplicationRecord.admin_attributes)
    def self.admin_attributes
      {
        friendly_name: { form_options: { disabled: true } },
        value: {
          form_options: lambda do |obj|
            spec = ALL_FEATURES.find do |v|
              v[:var] == obj.var.to_sym
            end
            return {} unless spec

            { as: spec[:type] }
          end
        }
      }
    end

    # @return (see ApplicationRecord.admin_configuration)
    def self.admin_configuration
      { no_create: true, no_delete: true }
    end

    # @return [String] Friendly name of this page (looked up in locale)
    def friendly_name
      ret = I18n.t("feature_flags.#{var}", default: '')
      return var if ret.blank?
      ret
    end

    # Ensure that all of the variables are stored in the database for the
    # administration console
    def self.save_to_db
      ALL_FEATURES.each do |f|
        Admin::FeatureFlags[f[:var]] = Admin::FeatureFlags[f[:var]]
      end
    end
  end
end
