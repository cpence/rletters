
RSpec.configure do |config|
  # We're going to use database_cleaner, so we don't need RSpec's transactional
  # fixture support
  config.use_transactional_fixtures = false

  config.before(:suite) do
    # Prepare the database
    DatabaseRewinder.clean_all
  end

  config.after(:example) do
    DatabaseRewinder.clean
  end
end
