# -*- encoding : utf-8 -*-
require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RLetters
  # Central application class, started by Rails
  class Application < Rails::Application
    # Custom directories with classes and modules
    config.eager_load_paths << config.root.join('lib').to_s
  end
end
