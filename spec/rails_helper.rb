# SimpleCov configuration has to be the very first thing we load
require 'simplecov_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
if Rails.env.production?
  abort("The Rails environment is running in production mode!")
end

require 'spec_helper'
require 'rspec/rails'
require 'rspec/active_job'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Double-check that the schema is current
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  config.before(:example) do
    # Reset the locale and timezone to defaults on each new test
    I18n.locale = I18n.default_locale
    Time.zone = 'Eastern Time (US & Canada)'
  end

  config.around(:each, verify_stubs: false) do |ex|
    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = false
      ex.run
      mocks.verify_partial_doubles = true
    end
  end

  # Add a variety of test helpers
  config.include FactoryGirl::Syntax::Methods
  config.include ActiveJob::TestHelper
  config.include QueHelpers
  config.include RSpec::ActiveJob
  config.include StubConnection
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include ParseJson, type: :request
end
