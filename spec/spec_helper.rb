# -*- encoding : utf-8 -*-
# rubocop:disable AvoidGlobalVars
require 'rubygems'

# Coverage setup
if ENV['COVERAGE'] || (ENV['TRAVIS'] && ENV['TRAVIS_RUBY_VERSION'] == '2.0')
  require 'simplecov'

  if ENV['TRAVIS']
    # Store coverage with Coveralls
    require 'coveralls'
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  else
    # Output our own report
    SimpleCov.coverage_dir('/spec/coverage')
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

    # Filter the few classes we explicitly can't get coverage for
    add_filter '/lib/ner_analyzer.rb'
    add_filter '/lib/jobs/analysis/named_entities.rb'

    add_group 'Models', '/app/models/'
    add_group 'Controllers', '/app/controllers/'
    add_group 'Mailers', '/app/mailers/'
    add_group 'Helpers', '/app/helpers/'
    add_group 'Administration', '/app/admin/'
    add_group 'Libraries', '/lib/'
  end
end

# Standard setup for RSpec
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Switch to the new RSpec syntax
  config.expect_with(:rspec) { |e| e.syntax = :expect }
  config.mock_with(:rspec) { |m| m.syntax = :expect }

  config.color_enabled = true
  config.tty = true
  config.order = 'random'

  config.infer_base_class_for_anonymous_controllers = true
  # Remove the next line for RSpec 3
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # We're going to use database_cleaner, so we don't need RSpec's transactional
  # fixture support
  config.use_transactional_fixtures = false

  # For testing, the NLP tool must be present in vendor/nlp/nlp-tool
  if File.exist?(Rails.root.join('vendor', 'nlp', 'nlp-tool'))
    Admin::Setting.nlp_tool_path = Rails.root.join('vendor', 'nlp', 'nlp-tool').to_s
    config.filter_run_excluding nlp: false
  else
    config.filter_run_excluding nlp: true
  end

  config.before(:suite) do
    # Prepare the database
    DatabaseCleaner.clean_with(:truncation)
    load Rails.root.join('db', 'seeds.rb')

    # Use transactions to clean database
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    # Reset the locale and timezone to defaults on each new test
    I18n.locale = I18n.default_locale
    Time.zone = 'Eastern Time (US & Canada)'

    # Reset database after each test
    DatabaseCleaner.start
  end

  config.after(:each) do
    # Clean the database after each test
    DatabaseCleaner.clean
  end

  # Add a variety of test helpers
  config.include Devise::TestHelpers, type: :controller
  config.include FactoryGirl::Syntax::Methods
  config.include SearchControllerQuery, type: :view
  config.include ParseJson, type: :request
  config.include StubConnection
end
