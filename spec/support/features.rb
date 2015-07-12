
# Use capybara-webkit for everything
Capybara.default_driver = :webkit
Capybara.javascript_driver = :webkit

RSpec.configure do |config|
  config.before(:example, type: :feature) do
    # Don't try to fetch Google Javascript, etc.
    page.driver.block_unknown_urls

    # Run tasks inline
    Resque.inline = true
  end

  config.after(:example, type: :feature) do
    Resque.inline = false
  end
end
