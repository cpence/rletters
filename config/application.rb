# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "sprockets/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module RLetters
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Require attributes to be whitelisted to be available for mass assignment
    config.active_record.whitelist_attributes = true
    
    # Generate all URLs with trailing slashes
    config.action_controller.default_url_options = { :trailing_slash => true }
    
    # Default to no tests generated
    config.generators do |g|
      g.test_framework nil
    end
    
    # Add vendor locales (for CLDR files)
    config.i18n.load_path += Dir[Rails.root.join('vendor', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :'en-US'

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.paths << Rails.root.join('public', 'static_assets')

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end
