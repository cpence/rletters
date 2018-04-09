require 'test_helper'
require 'selenium/webdriver'

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu no-sandbox) }

    # Uncomment this instead to watch the tests happen live
    # chromeOptions: { args: %w(disable-gpu no-sandbox) }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :headless_chrome

  setup do
    Capybara.current_window.resize_to(1400, 1400)
  end

  # Helpers for making our system tests much cleaner
  include SystemAdminHelper
  include SystemDatasetHelper
  include SystemStubHelper
  include SystemUserHelper
end
