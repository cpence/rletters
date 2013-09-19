# -*- encoding : utf-8 -*-

# Set the Airbrake key and start up Airbrake, if available
if ActiveRecord::Base.connection.tables.include?('settings')
  unless Setting.airbrake_key.blank?
    begin
      require 'airbrake'

      Airbrake.configure do |config|
        config.api_key = Setting.airbrake_key
      end

      # Connect Airbrake to Resque.  The 'multiple' backend is already enabled
      # in core_ext, when we define our custom AnalysisTask error receiver.
      require 'resque/failure/airbrake'
      Resque::Failure::Multiple.classes << Resque::Failure::Airbrake
    rescue LoadError
      puts 'WARNING: Cannot load the Airbrake gem, error reporting disabled'
    end
  end
end
