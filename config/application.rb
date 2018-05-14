# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'
Bundler.require(*Rails.groups)

module RLetters
  # Central application class, started by Rails
  class Application < Rails::Application
    # Initialize configuration defaults for current config standard here
    config.load_defaults 5.2

    # Custom directories with classes and modules to be loaded. This has to be
    # done here rather than in an initializer, as this array gets frozen.
    config.eager_load_paths << config.root.join('lib').to_s
    config.eager_load_paths << config.root.join('app', 'jobs', 'concerns').to_s

    # Run errors through the routing system, showing error pages in all cases.
    config.exceptions_app = routes
    config.consider_all_requests_local = false
    config.action_dispatch.show_exceptions = true

    # Enable the public file server if requested
    config.public_file_server.enabled =
      (ENV['RAILS_SERVE_STATIC_FILES'] || 'true').to_bool

    # Log at :info with lograge, to try to make logs readable
    config.lograge.enabled = true
    config.log_level = :info

    if (ENV['RAILS_LOG_TO_STDOUT'] || 'true').to_bool
      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger::INFO
    else
      config.paths['log'] = Rails.root.join('tmp', 'rletters.log')
    end
  end
end
