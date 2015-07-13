require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RLetters
  # Central application class, started by Rails
  class Application < Rails::Application
    # Save the schema in SQL
    config.active_record.schema_format = :sql

    # Custom directories with classes and modules
    config.eager_load_paths << config.root.join('lib').to_s
    config.eager_load_paths << config.root.join('app', 'jobs', 'concerns').to_s

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
