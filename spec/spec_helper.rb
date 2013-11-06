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
    add_filter '/config/'
    add_filter '/db/'
    add_filter '/vendor/bundle/'
    add_filter '.haml'
    add_filter '.erb'
    add_filter '.builder'

    # Filter things only JRuby uses
    add_filter '/lib/core_ext/activerecord_base_logger.rb'
    add_filter '/lib/core_ext/java_print_stream.rb'
    add_filter '/lib/core_ext/nokogiri_xml_node_attributes.rb'

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

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

require 'capybara/rspec'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Switch to the new RSpec syntax
  config.expect_with(:rspec) { |e| e.syntax = :expect }
  config.mock_with(:rspec) { |m| m.syntax = :expect }

  config.color_enabled = true
  config.tty = true
  config.formatter = 'Fuubar'
  config.order = 'random'

  config.infer_base_class_for_anonymous_controllers = true
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # We're going to use database_cleaner, so we don't need RSpec's transactional
  # fixture support
  config.use_transactional_fixtures = false

  # Don't test the NLP stuff if it's not installed (e.g., on Travis)
  config.filter_run_excluding nlp: !NLP_ENABLED

  config.before(:suite) do
    # Load the DB schema, since we're using in-memory SQLite
    load Rails.root.join('db', 'schema.rb')

    # Seed the DB.  I know that people object to this sort of thing, but I want
    # things like the standard package of CSL styles to be available without
    # my having to write giant XML CSL-style factories.
    load Rails.root.join('db', 'seeds.rb')

    # Activate bundled Solr server, if available
    if File.exists? Rails.root.join('vendor', 'solr')
      Dir.chdir(Rails.root.join('vendor', 'solr')) do
        system(Rails.root.join('vendor', 'solr', 'start').to_s)
      end
    end

    # Use transactions to clean database
    DatabaseCleaner.strategy = :transaction
  end

  config.after(:suite) do
    # Destroy Solr server
    if File.exists? Rails.root.join('vendor', 'solr')
      system(Rails.root.join('vendor', 'solr', 'stop').to_s)
    end
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

  # Add helpers for Devise
  config.include Devise::TestHelpers, type: :controller

  # Add helpers for running Solr queries in view specs
  config.include SearchControllerQuery, type: :view

  # Add helpers for stubbing HTTP connections
  config.include StubConnection
end
