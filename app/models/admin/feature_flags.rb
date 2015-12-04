
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

    ALL_FEATURES = [
      { var: :maintenance_message, type: :string }
    ]

    # All available feature flags, for display in the administration panel
    def self.all_features
      ALL_FEATURES
    end
  end
end
