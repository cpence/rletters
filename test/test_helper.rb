ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Load some gems
require 'mocha/mini_test'
require 'webmock/minitest'

# Require all of my test helpers
Dir[Rails.root.join('test', 'helpers', '**', '*_helper.rb')].each do |helper|
  require helper
end

# Global configuration
WebMock.disable_net_connect!(allow_localhost: true)

class ActiveSupport::TestCase
  # Activate factory_girl
  include FactoryGirl::Syntax::Methods

  # General test helpers
  include StubConnectionHelper

  # Code for making our system tests much cleaner
  include SystemAdminHelper
  include SystemDatasetHelper
  include SystemStubHelper
  include SystemUserHelper
end
