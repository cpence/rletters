# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module RLetters
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths << "#{config.root}/lib"
    config.autoload_paths << "#{config.root}/app/models/admin"
    config.autoload_paths << "#{config.root}/app/models/dataset"
    config.autoload_paths << "#{config.root}/app/models/user"

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Require attributes to be whitelisted to be available for mass assignment
    config.active_record.whitelist_attributes = true
    
    # Generate all URLs with trailing slashes
    config.action_controller.default_url_options = { :trailing_slash => true }
        
    # Add vendor locales (for CLDR files)
    config.i18n.load_path += Dir[Rails.root.join('vendor', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :'en-US'

    # Configure the default encoding used in templates.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [ :password, :password_confirmation ]

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.precompile += [/active_admin.(css|js)$/]

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Generator configuration
    config.generators do |generator|
      generator.orm :active_record
      generator.template_engine :haml
      generator.test_framework :rspec,
        :view_specs => false, :routing_specs => false
      generator.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end
  end
end
