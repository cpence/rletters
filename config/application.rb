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
    config.filter_parameters.concat([:password, :file_contents])
    config.active_support.deprecation = Rails.env.test? ? :stderr : :log

    unless Rails.env.test?
      log_level = (ENV['VERBOSE_LOGS'] == 'true') ? 'DEBUG' : 'WARN'
      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger.const_get(log_level)
      config.log_level = log_level
    end

    # ActiveRecord configuration
    config.active_record.schema_format = :sql

    # Cookie configurations
    config.session_store(:cookie_store,
                         key: "_#{ENV['APP_NAME'].underscore}_session")
    config.action_dispatch.cookies_serializer = :json

    # Code caching and loading
    config.cache_classes = true
    config.eager_load = true

    # Asset configuration
    config.assets.version = '1.0'
    config.assets.compile = false
    config.assets.digest = true
    config.assets.debug = false

    config.assets.js_compressor = :uglifier
    # config.assets.css_compressor = :sass

    Rails.root.join('vendor', 'assets', 'node_modules').to_s.tap do |path|
      config.assets.paths << path
      config.sass.load_paths << path
    end

    # Precompile all and only the right things
    config.assets.precompile = [
      'application.js',
      'application.css',
      %r(bootstrap-sass/assets/fonts/bootstrap/[\w-]+\.(?:eot|svg|ttf|woff2?)$)
    ]

    # Minimum Sass number precision required by bootstrap-sass
    sass_precision = [8, ::Sass::Script::Value::Number.precision].max
    ::Sass::Script::Value::Number.precision = sass_precision

    config.serve_static_files = true
    unless Rails.env.test?
      config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'
    end

    # Error reporting
    config.exceptions_app = routes
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
