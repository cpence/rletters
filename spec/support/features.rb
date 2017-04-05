# Use Poltergeist for everyting
# require 'capybara/poltergeist'

# Capybara.default_driver = :poltergeist
# Capybara.javascript_driver = :poltergeist

# Use capybara-webkit for everything
Capybara.default_driver = :webkit
Capybara.javascript_driver = :webkit

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
  config.skip_image_loading
end
