# -*- encoding : utf-8 -*-

# Set the Airbrake key and start up Airbrake, if available
if ActiveRecord::Base.connection.tables.include?('setting')
  unless Setting.airbrake_key.blank?
    begin
      require 'airbrake'

      Airbrake.configure do |config|
        config.api_key = Setting.airbrake_key
      end

      # Connect Airbrake to Resque
      require 'resque/failure/multiple'
      require 'resque/failure/airbrake'
      Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Airbrake]
      Resque::Failure.backend = Resque::Failure::Multiple
    rescue LoadError
      puts 'WARNING: Cannot load the Airbrake gem, error reporting disabled'
    end
  end
end
