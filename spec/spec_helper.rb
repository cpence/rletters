
# Coverage setup
if ENV['TRAVIS'] || ENV['COVERAGE']
  require 'simplecov'
  if ENV['TRAVIS']
    require 'codeclimate-test-reporter'
    SimpleCov.formatter = CodeClimate::TestReporter::Formatter
  end

  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/features/'
    add_filter '/config/'
    add_filter '/db/'
    add_filter '/vendor/bundle/'
    add_filter '.haml'
    add_filter '.erb'
    add_filter '.builder'
  end

  SimpleCov.at_exit do
    # We want to disable WebMock before we send results to Code Climate, or
    # it'll block the request
    WebMock.allow_net_connect!

    SimpleCov.result.format!
  end
end

# Standard setup for RSpec
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/active_job'

# Double-check that the schema is current
ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Switch to the new RSpec syntax
  config.expect_with(:rspec) do |e|
    e.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with(:rspec) do |m|
    m.verify_partial_doubles = true
  end

  # Enable re-running failures automatically
  status_path = Rails.root.join('spec','status.txt')
  config.example_status_persistence_file_path = status_path

  config.disable_monkey_patching!
  config.color = true
  config.tty = true
  config.order = :random

  config.before(:example) do
    # Reset the locale and timezone to defaults on each new test
    I18n.locale = I18n.default_locale
    Time.zone = 'Eastern Time (US & Canada)'
  end

  config.after(:example) do
    # Clean out the job queues
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end

  # Add a variety of test helpers
  config.include FactoryGirl::Syntax::Methods
  config.include ActiveJob::TestHelper
  config.include RSpec::ActiveJob
  config.include StubConnection
  config.include Devise::TestHelpers, type: :controller
  config.include ParseJson, type: :request
  config.include Features::DatasetHelpers, type: :feature
  config.include Features::UserHelpers, type: :feature
end
