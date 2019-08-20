# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative 'support/simplecov'
require_relative '../config/environment'
require 'rails/test_help'

# Load some gems
require 'capybara/rails'
require 'mocha/minitest'
require 'webmock/minitest'

# Require all of my test helpers and assertions
(Dir[Rails.root.join('test', 'support', '**', '*_helper.rb')] +
Dir[Rails.root.join('test', 'support', '**', 'assert_*.rb')]).each do |helper|
  require helper
end

# Global configuration
WebMock.disable_net_connect!(
  allow_localhost: true,
  # Allow the chromedriver downloader to go get drivers for us
  allow: 'chromedriver.storage.googleapis.com'
)

# Helpers for all tests
module ActiveSupport
  class TestCase
    # Activate helpers from gems
    include FactoryBot::Syntax::Methods

    # General test helpers
    include StubConnectionHelper
  end
end

# Helpers for controller and integration tests
module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers
  end
end
