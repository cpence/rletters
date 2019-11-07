# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.4'

# Rails and basics
gem 'dotenv-rails'
gem 'lograge'
gem 'puma', '~> 3.11'
gem 'rails', '~> 6'
gem 'sentry-raven'

# Database, job queue, and related tools
gem 'ancestry', '~> 3', '>= 3.0.2'
gem 'delayed_job_active_record'
gem 'pg'
gem 'virtus'

# User authentication and administration
gem 'devise', '~> 4', '>= 4.7.1'
gem 'devise-i18n'

# Internationalization
gem 'rails-i18n', '= 6.0.0'
gem 'twitter_cldr'

# Textual analysis
gem 'distribution'
gem 'engtagger'
gem 'fast-stemmer'
gem 'lemmatizer'
gem 'rsolr', '>= 1.0.7'
gem 'rsolr-ext'

# Citation processing
gem 'bibtex-ruby', require: 'bibtex'

# Support for file attachments and exporting
gem 'aws-sdk-s3', require: false
gem 'marc'
gem 'rdf', '>= 0.3.5'
gem 'rdf-n3'
gem 'rdf-vocab'
gem 'rubyzip', '~> 1.3.0', require: 'zip'

# Asset tools and template generators
gem 'haml', '>= 5.1.0'
gem 'haml-rails', '~> 2.0'
gem 'kramdown'
gem 'nokogiri', '>= 1.10.4'
gem 'sassc-rails', '>= 2.1.1'
gem 'uglifier', '>= 1.3.0'

# Mail
gem 'bootstrap-email', '>= 0.2.6'
gem 'multi_mail'

# Testing
group :test, :development do
  gem 'capybara', '>= 2.15'
  # gem 'capybara-slow_finder_errors'
  gem 'factory_bot_rails'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'mocha', require: false
end

group :test do
  gem 'webdrivers', '~> 4.0', require: false
  gem 'webmock', '>= 3.5.0', require: false
  gem 'rails-controller-testing'
  gem 'simplecov', require: false
end

group :development do
  gem 'capistrano','~> 3.11', require: false
  gem 'capistrano-bundler', '~> 1.6', require: false
  gem 'capistrano-yarn', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-maintenance', '~> 1.2', require: false
  gem 'capistrano-sentry', require: false

  gem 'ed25519', '>= 1.2', '< 2.0'
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
end
