# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the relevant set of gems
Bundler.require(:default, Rails.env)

module RLetters

  # Central application class, started by Rails
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths << "#{config.root}/lib"

    # Generate all URLs with trailing slashes
    config.action_controller.default_url_options = { trailing_slash: true }

    # Add vendor locales (for CLDR files)
    config.i18n.load_path += Dir[Rails.root.join('vendor',
                                                 'locales',
                                                 '**',
                                                 '*.{rb,yml}').to_s]
    config.i18n.default_locale = :'en-US'

    # Configure the default encoding used in templates.
    config.encoding = Encoding::UTF_8

    # Bounce exceptions to the routing system
    config.exceptions_app = routes

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

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
                               view_specs: false,
                               routing_specs: false
      generator.fixture_replacement :factory_girl,
                                    dir: 'spec/factories'
    end
  end
end
