# -*- encoding : utf-8 -*-
require 'cucumber/rails'

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how
# your application behaves in the production environment, where an error page will
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

DatabaseCleaner.strategy = :transaction

SEED_TABLES = %w[
  admin_markdown_pages
  admin_uploaded_assets
  admin_uploaded_asset_files
  documents_stop_lists
  users_csl_styles
]

Cucumber::Rails::Database.javascript_strategy = :truncation, { except: SEED_TABLES }

# Set up the database for the first time
DatabaseCleaner.clean_with :truncation
load Rails.root.join('db', 'seeds.rb')
