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

    # Use Delayed Job in all cases; its configuration (see initializer) will
    # run jobs immediately in testing.
    config.active_job.queue_adapter = :delayed_job

    # Run errors through the routing system, showing error pages in all cases.
    config.exceptions_app = routes
    config.consider_all_requests_local = false
    config.action_dispatch.show_exceptions = true

    # Use the lowest log level to ensure availability of diagnostic information
    # when problems arise.
    config.lograge.enabled = true
    config.log_level = :debug

    if Rails.env.test?
      # In testing, save logs
      config.paths['log'] = Rails.root.join('tmp', 'test.log')
    else
      # Send all logs to stdout
      log_level = (ENV['VERBOSE_LOGS'] == 'true') ? 'DEBUG' : 'WARN'
      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger.const_get(log_level)
      config.log_level = log_level
    end
  end
end
