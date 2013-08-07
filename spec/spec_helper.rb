# -*- encoding : utf-8 -*-
# rubocop:disable AvoidGlobalVars
require 'rubygems'

# Coverage setup
if ENV['TRAVIS'] && ENV['TRAVIS_RUBY_VERSION'] == '2.0'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/config/'
    add_filter '/db/'
    add_filter '/vendor/bundle/'

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

  # Psych serializes cassette data as binary, which makes them not human-
  # readable.  When recording new cassettes, fire up Ruby 1.9 and uncomment
  # this line.
  # c.default_cassette_options = { serialize_with: :syck }
end

# Standard setup for RSpec
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'fileutils'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = 'documentation'
  config.order = 'random'

  config.mock_with :rspec
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = true
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before(:suite) do
    # If there's no downloads directory, create it now and tear it up later
    unless File.exist? "#{::Rails.root}/downloads"
      FileUtils.mkdir "#{::Rails.root}/downloads"
      $destroy_downloads = true
    end

    # Speed up testing by deferring garbage collection
    DeferredGarbageCollection.start

    # Load the DB schema, since we're using in-memory SQLite
    load Rails.root.join('db', 'schema.rb')

    # Seed the DB.  I know that people object to this sort of thing, but I want
    # things like the standard package of CSL styles to be available without
    # my having to write giant XML CSL-style factories.
    load Rails.root.join('db', 'seeds.rb')
  end

  config.after(:suite) do
    # Clean up GC
    DeferredGarbageCollection.reconsider

    # Destroy downloads directory
    FileUtils.rm_rf "#{::Rails.root}/downloads" if $destroy_downloads
  end

  config.before(:each) do
    # Reset the locale and timezone to defaults on each new test
    I18n.locale = I18n.default_locale
    Time.zone = 'Eastern Time (US & Canada)'
  end

  # Add helpers for Devise
  config.include Devise::TestHelpers, type: :controller
end
