# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'
Bundler.require(*Rails.groups)

module RLetters
  # Central application class, started by Rails
  class Application < Rails::Application
    # Initialize configuration defaults for current config standard here
    config.load_defaults 5.2

    # Custom directories with classes and modules to be eager-loaded.
    config.eager_load_paths << config.root.join('lib').to_s

    # Add autoload paths for 'lib' and its subdirectories.
    config.autoload_paths << config.root.join('lib').to_s
    config.autoload_paths += Dir[config.root.join('lib')]

    # Show error pages in all environments
    config.consider_all_requests_local = false
    config.action_dispatch.show_exceptions = true

    # Enable the public file server if requested
    config.public_file_server.enabled =
      (ENV['RAILS_SERVE_STATIC_FILES'] || 'true').to_bool

    # Log at :info with lograge, to try to make logs readable
    config.lograge.enabled = true
    config.lograge.custom_options = lambda do |event|
      { exception: event.payload[:exception],
        exception_object: event.payload[:exception_object] }
    end
    config.log_level = :info

    if (ENV['RAILS_LOG_TO_STDOUT'] || 'true').to_bool
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
