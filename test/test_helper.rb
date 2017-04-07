ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

# Require all of my test helpers
Dir[Rails.root.join('test', 'helpers', '**', '*_helper.rb')].each do |helper|
  require helper
end

class ActiveSupport::TestCase
  # Activate factory_girl
  include FactoryGirl::Syntax::Methods

  # Code for making our system tests much cleaner
  include SystemAdminHelper
  include SystemDatasetHelper
  include SystemStubHelper
  include SystemUserHelper
end
