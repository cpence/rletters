# -*- encoding : utf-8 -*-

# Set the Airbrake key and start up Airbrake, if available
if ActiveRecord::Base.connection.tables.include?('setting')
  unless Setting.airbrake_key.blank?
    require 'airbrake'
    
    Airbrake.configure do |config|
      config.api_key = Setting.airbrake_key
    end
  end
end
