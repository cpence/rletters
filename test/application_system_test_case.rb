require 'test_helper'

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
  config.skip_image_loading
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :webkit
end
