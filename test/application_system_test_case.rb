require 'test_helper'

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
  config.skip_image_loading
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :webkit

  setup do
    Capybara.current_window.resize_to(1400, 1400)
  end

  # Helpers for making our system tests much cleaner
  include SystemAdminHelper
  include SystemDatasetHelper
  include SystemStubHelper
  include SystemUserHelper
end
