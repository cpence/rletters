# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module RLetters

  # Central application class, started by Rails
  class Application < Rails::Application
    # Custom directories with classes and modules
    config.eager_load_paths << "#{config.root}/lib"

    # Generate all URLs with trailing slashes
    config.action_controller.default_url_options = { trailing_slash: true }

    # Add vendor locales (for CLDR files)
    config.i18n.load_path += Dir[Rails.root.join('vendor',
                                                 'locales',
                                                 '**',
                                                 '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # Find the local fonts folder
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # Use the 'full_page' layout for all Devise views
    config.to_prepare do
      Devise::SessionsController.layout 'full_page'
      Devise::RegistrationsController.layout 'full_page'
      Devise::ConfirmationsController.layout 'full_page'
      Devise::UnlocksController.layout 'full_page'
      Devise::PasswordsController.layout 'full_page'
    end

    # Bounce exceptions to the routing system
    config.exceptions_app = routes

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
