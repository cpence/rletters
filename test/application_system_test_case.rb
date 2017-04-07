require 'test_helper'

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :webkit

  teardown do
    take_failed_screenshot
    Capybara.reset_sessions!
  end
end
