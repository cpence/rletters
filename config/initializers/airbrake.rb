# -*- encoding : utf-8 -*-

# Set the Airbrake key and start up Airbrake, if available
if ActiveRecord::Base.connection.tables.include?('settings')
  unless Settings.airbrake_key.blank?
    Airbrake.configure do |config|
      config.api_key = Settings.airbrake_key
    end
  end
end
