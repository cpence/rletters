# -*- encoding : utf-8 -*-

# Set the Airbrake key and start up Airbrake, if available
if ActiveRecord::Base.connection.tables.include?('admin_settings')
  if Admin::Setting.airbrake_key.present?
    begin
      require 'airbrake'

      Airbrake.configure do |config|
        config.api_key = Admin::Setting.airbrake_key
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
