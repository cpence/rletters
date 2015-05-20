require 'rubygems'

NO_TRUNCATE_TABLES = %w(admin_administrators admin_markdown_pages
                        admin_uploaded_asset_files admin_uploaded_assets
                        documents_stop_lists users_csl_styles)

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

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Double-check that the schema is current
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Switch to the new RSpec syntax
  config.expect_with(:rspec) do |e|
    e.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with(:rspec) do |m|
    m.verify_partial_doubles = true
  end

  config.disable_monkey_patching!
  config.color = true
  config.tty = true
  config.order = :random
  #config.order = :defined
  config.fail_fast = true

  # We're going to use database_cleaner, so we don't need RSpec's transactional
  # fixture support
  config.use_transactional_fixtures = false

  config.before(:suite) do
    # Prepare the database
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:example) do |example|
    puts "STARTING #{example.full_description}"

    # Reset the locale and timezone to defaults on each new test
    I18n.locale = I18n.default_locale
    Time.zone = 'Eastern Time (US & Canada)'

    # I'm not sure why this has stopped being called, but call it manually
    # if example.metadata[:type].in?([:controller, :mailer, :decorator])
    #   Draper::ViewContext.clear!
    # end

    # Use transactions to clean database for non-feature tests, truncation for
    # features that use capybara-webkit.
    # if example.metadata[:type] == :feature
      DatabaseCleaner.strategy = :truncation, { except: NO_TRUNCATE_TABLES }
    # else
    #   DatabaseCleaner.strategy = :transaction
    # end

    DatabaseCleaner.cleaning do
      puts "   ...CLEAN DONE, RUNNING"
      example.run
      puts "   ...RUN DONE"
    end
  end

  # Add a variety of test helpers
  config.include FactoryGirl::Syntax::Methods
  config.include StubConnection
  config.include Devise::TestHelpers, type: :controller
  config.include ParseJson, type: :request
  config.include Features::DatasetHelpers, type: :feature
  config.include Features::UserHelpers, type: :feature
end

# FactoryGirl::SyntaxRunner.include(RSpec::Mocks::ExampleMethods)

Capybara.default_driver = :webkit
Capybara.javascript_driver = :webkit
