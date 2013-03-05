# -*- encoding : utf-8 -*-
require 'rubygems'

# Coverage setup
if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end

# Standard setup for RSpec
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'webmock/rspec'
  
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.formatter = 'Fuubar'
  config.order = 'random'
  
  config.mock_with :rspec
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = true

  config.before(:suite) do    
    # Speed up testing by deferring garbage collection
    DeferredGarbageCollection.start

    # Seed the DB.  I know that people object to this sort of thing, but I want
    # things like the standard package of CSL styles to be available without
    # my having to write giant XML CSL-style factories.
    SeedFu.quiet = true
    SeedFu.seed
  end
  
  config.after(:suite) do
    # Clean up GC
    DeferredGarbageCollection.reconsider
  end
  
  config.before(:each) do
    # Disable net connections outbound
    WebMock.enable!
    WebMock.disable_net_connect!(:allow_localhost => true)
    
    # Reset the locale and timezone to defaults on each new test
    I18n.locale = I18n.default_locale
    Time.zone = 'Eastern Time (US & Canada)'
  end

  # Add helpers for Devise and for breaking the Solr server
  config.include Devise::TestHelpers, :type => :controller
  config.extend SolrServerHelper
end
