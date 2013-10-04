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

    # Filter the few classes we explicitly can't get coverage for
    add_filter 'lib/ner_analyzer.rb'
    add_filter 'lib/jobs/analysis/named_entities.rb'

    add_group 'Models', '/app/models/'
    add_group 'Controllers', '/app/controllers/'
    add_group 'Mailers', '/app/mailers/'
    add_group 'Helpers', '/app/helpers/'
    add_group 'Administration', '/app/admin/'
    add_group 'Libraries', '/lib/'
  end
end

# VCR setup
require 'vcr'
require 'webmock/rspec'

VCR.configure do |c|
  c.configure_rspec_metadata!
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock

  c.default_cassette_options = { allow_playback_repeats: true,
                                 record: :none,
                                 match_requests_on: [ :method, :uri, :body ] }
end

# Standard setup for RSpec
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'fileutils'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Switch to the new RSpec syntax; but not to the expectation syntax yet, as
  # our have_tag matcher gem uses the old syntax.
  # config.expect_with(:rspec) { |e| e.syntax = :expect }
  config.mock_with(:rspec) { |m| m.syntax = :expect }

  config.color_enabled = true
  config.tty = true
  config.formatter = 'Fuubar'
  config.order = 'random'

  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = true
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # Don't test the NLP stuff if it's not installed (e.g., on Travis)
  config.filter_run_excluding nlp: true unless NLP_ENABLED

  config.before(:suite) do
    # Load the DB schema, since we're using in-memory SQLite
    load Rails.root.join('db', 'schema.rb')

    # Seed the DB.  I know that people object to this sort of thing, but I want
    # things like the standard package of CSL styles to be available without
    # my having to write giant XML CSL-style factories.
    load Rails.root.join('db', 'seeds.rb')
  end

  config.before(:each) do
    # Reset the locale and timezone to defaults on each new test
    I18n.locale = I18n.default_locale
    Time.zone = 'Eastern Time (US & Canada)'
  end

  # Add helpers for Devise
  config.include Devise::TestHelpers, type: :controller

  # Add helpers for running Solr queries in view specs
  config.include SearchControllerQuery, type: :view

  # Add helpers for dealing with analysis job views
  config.include JobViewHelper, type: :view
end
