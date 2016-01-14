# SimpleCov configuration has to be the very first thing we load
require 'simplecov_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'spec_helper'
require 'rspec/rails'
require 'rspec/active_job'

# Double-check that the schema is current
ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
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
  config.include QueHelpers
  config.include RSpec::ActiveJob
  config.include StubConnection
  config.include Devise::TestHelpers, type: :controller
  config.include ParseJson, type: :request
  config.include Features::AdminHelpers, type: :feature
  config.include Features::DatasetHelpers, type: :feature
  config.include Features::StubHelpers, type: :feature
  config.include Features::UserHelpers, type: :feature
end
