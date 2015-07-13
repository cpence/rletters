
# Use capybara-webkit for everything
Capybara.default_driver = :webkit
Capybara.javascript_driver = :webkit

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
end
