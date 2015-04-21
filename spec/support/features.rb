
RSpec.configure do |config|
  config.include Features::DatasetHelpers, type: :feature
  config.include Features::UserHelpers, type: :feature

  config.before(:example, type: :feature) do
    page.driver.block_unknown_urls
    Resque.inline = true
  end

  config.after(:example, type: :feature) do
    Resque.inline = false
  end
end
