# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Enable caching.
  config.action_controller.perform_caching = true

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to
  # raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Specifies the header that your server uses for sending files. Default to
  # nginx.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force SSL if requested
  config.force_ssl = (ENV['HTTPS_ONLY'] || 'false').to_bool
  config.ssl_options = {
    hsts: {
      subdomains: true
    }
  }

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
