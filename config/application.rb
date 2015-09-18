require File.expand_path('../boot', __FILE__)
require 'rails/all'
Bundler.require(*Rails.groups)

module RLetters
  # Central application class, started by Rails
  #
  # There's a lot more configuration here than you might expect, as a
  # consequence of twelve-factor development/production parity
  # <12factor.net/dev-prod-parity>.
  class Application < Rails::Application
    # Custom directories with classes and modules to be loaded
    config.eager_load_paths << config.root.join('lib').to_s
    config.eager_load_paths << config.root.join('app', 'jobs', 'concerns').to_s

    # Configure logging to stdout (except in testing), and clean up the logs
    config.lograge.enabled = true
    config.active_support.deprecation = Rails.env.test? ? :stderr : :log

    unless Rails.env.test?
      log_level = (ENV['VERBOSE_LOGS'] == 'true') ? 'DEBUG' : 'WARN'
      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger.const_get(log_level)
      config.log_level = log_level
    end

    # ActiveRecord configuration
    config.active_record.schema_format = :sql

    # Code caching and loading
    config.cache_classes = true
    config.eager_load = true

    # Asset configuration (automatically compile assets in testing)
    config.assets.compile = Rails.env.test?
    config.assets.digest = true

    config.assets.js_compressor = :uglifier
    # config.assets.css_compressor = :sass

    config.serve_static_files = true
    config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

    # Error reporting
    config.consider_all_requests_local = false
    config.action_dispatch.show_exceptions = true
    config.active_record.raise_in_transactional_callbacks = true
    config.action_mailer.raise_delivery_errors = false

    # Use que for job queueing (except in testing)
    config.active_job.queue_adapter = Rails.env.test? ? :test : :que

    # Enable caching (except in testing)
    config.action_controller.perform_caching = !Rails.env.test?

    # Miscellaneous settings
    config.i18n.fallbacks = true

    # Enable mailer previews if requested
    if ENV['MAILER_PREVIEWS'] == 'true'
      config.action_mailer.preview_path = Rails.root.join('spec', 'mailers',
                                                          'previews')
    end

    # A few remaining configuration settings just for the test environment,
    # put them here instead of splitting them out into test.rb so all of our
    # configuration is in one place
    if Rails.env.test?
      # Move the log file, since we're keeping it, but don't have '/log/'
      config.paths['log'] = 'tmp/test.log'

      # Disable request forgery protection in test environment
      config.action_controller.allow_forgery_protection = false

      # Tell Action Mailer not to deliver emails to the real world
      config.action_mailer.delivery_method = :test
    end
  end
end
