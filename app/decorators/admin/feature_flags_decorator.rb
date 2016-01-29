
module Admin
  # Decorate FeatureFlags objects
  class FeatureFlagsDecorator < ApplicationRecordDecorator
    decorates Admin::FeatureFlags
    delegate_all
  end
end
