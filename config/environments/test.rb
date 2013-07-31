# -*- encoding : utf-8 -*-
RLetters::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  
  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"

  # Let the proper 404/422/500 pages produce errors
  config.consider_all_requests_local = false
  config.action_dispatch.show_exceptions = true
  
  # Don't cache anything in the controllers
  config.action_controller.perform_caching = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  
  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr
end
