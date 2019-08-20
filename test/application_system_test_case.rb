# frozen_string_literal: true

require 'test_helper'
require 'webdrivers/chromedriver'
require 'selenium/webdriver'

# Set a new command name to be sure that we don't clobber merged tests
SimpleCov.command_name 'test:system' if ENV['TRAVIS'] || ENV['COVERAGE']

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium_chrome_headless

  setup do
    Capybara.current_window.resize_to(1400, 1400)
  end

  # Helpers for making our system tests much cleaner
  include SystemAdminHelper
  include SystemDatasetHelper
  include SystemStubHelper
  include SystemUserHelper
end
