# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'
Bundler.require(*Rails.groups)

# Load our core extensions here, before we even configure the application
core_ext_files = File.expand_path('../lib/core_ext/**/*.rb', __dir__)
Dir[core_ext_files].each { |l| require l }

module RLetters
  # Central application class, started by Rails
  class Application < Rails::Application
    # Initialize configuration defaults for current config standard here
    config.load_defaults 5.2
    config.autoloader = :zeitwerk

    # Disable a Rails 6.1 deprecation warning that we're already ready for
    config.action_dispatch.return_only_media_type_on_content_type = false

    # Show error pages in all environments
    config.consider_all_requests_local = false
    config.action_dispatch.show_exceptions = true

    # Enable the public file server if requested
    config.public_file_server.enabled =
      (ENV['RAILS_SERVE_STATIC_FILES'] || 'true').to_boolean

    # Log at :info with lograge, to try to make logs readable
    config.lograge.enabled = true
    config.lograge.custom_options = lambda do |event|
      { exception: event.payload[:exception],
        exception_object: event.payload[:exception_object] }
    end
    config.log_level = :info

    if (ENV['RAILS_LOG_TO_STDOUT'] || 'true').to_boolean
      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger::INFO
    else
      config.paths['log'] = Rails.root.join('tmp', 'rletters.log')
    end

    # Set mailer defaults
    config.action_mailer.default_url_options =
      { host: ENV['MAIL_DOMAIN'] || 'example.com' }
  end
end
