ENV['RAILS_ENV'] ||= 'test'
require_relative 'support/simplecov'
require_relative '../config/environment'
require 'rails/test_help'

# Load some gems
require 'mocha/mini_test'
require 'webmock/minitest'

# Require all of my test helpers and assertions
(Dir[Rails.root.join('test', 'support', '**', '*_helper.rb')] +
Dir[Rails.root.join('test', 'support', '**', 'assert_*.rb')]).each do |helper|
  require helper
end

# Global configuration
WebMock.disable_net_connect!(allow_localhost: true)

# Helpers for all tests
class ActiveSupport::TestCase
  # Activate helpers from gems
  include FactoryGirl::Syntax::Methods

  # General test helpers
  include QueJobHelper
  include StubConnectionHelper
end

# Helpers for controller and integration tests
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
