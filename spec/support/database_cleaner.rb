
RSpec.configure do |config|
  # We're going to use database_cleaner, so we don't need RSpec's transactional
  # fixture support
  config.use_transactional_fixtures = false

  config.before(:suite) do
    # Prepare the database
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:example) do |example|
    # Use transactions to clean database for non-feature tests, truncation for
    # features that use capybara-webkit.
    if example.metadata[:type] == :feature
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
    DatabaseCleaner.start
  end

  config.after(:example) do
    DatabaseCleaner.clean
  end
end
