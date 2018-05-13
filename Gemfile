# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

# Rails
gem 'rails', '~> 5.2.0'

# Twelve factor app glue
gem 'dotenv-rails'
gem 'lograge'
gem 'puma', '~> 3.11'

# Database and related tools
gem 'ancestry', '~> 3', '>= 3.0.2'
gem 'daemons'
gem 'delayed_job_active_record'
gem 'pg'
gem 'virtus'

# User authentication and administration
gem 'devise', '~> 4', '>= 4.4.0'
gem 'devise-i18n'

# Internationalization
gem 'rails-i18n', '= 5.1.1'
gem 'twitter_cldr'

# Textual analysis
gem 'cheetah'
gem 'distribution'
gem 'engtagger'
gem 'fast-stemmer'
gem 'lemmatizer'
gem 'rsolr', '>= 1.0.7'
gem 'rsolr-ext'

# Citation processing
gem 'bibtex-ruby', require: 'bibtex'

# Support for file attachments and exporting
gem 'aws-sdk-s3'
gem 'marc'
gem 'rdf', '>= 0.3.5'
gem 'rdf-n3'
gem 'rdf-vocab'
gem 'rubyzip', '>= 1.1.0', require: 'zip'

# Asset tools and template generators
gem 'haml'
gem 'haml-rails'
gem 'kramdown'
gem 'nokogiri'
gem 'sass-rails', '~> 5.0'

gem 'mini_racer'
gem 'uglifier', '>= 1.3.0'

gem 'inky-rb', require: 'inky'
gem 'multi_mail'
gem 'premailer-rails'

# Testing
group :test, :development do
  gem 'capybara', '>= 2.15', '< 4.0'
  # gem 'capybara-slow_finder_errors'
  gem 'factory_bot_rails'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'mocha', require: false
end

group :test do
  gem 'capybara-selenium'
  gem 'chromedriver-helper'

  gem 'webmock', '>= 1.22.6', require: false

  gem 'rails-controller-testing'
  gem 'simplecov', require: false
end

group :development do
  # Tools that we need for developers, but not for any deployment or testing
  gem 'brakeman', require: false
  gem 'bundle-audit', require: false
  gem 'haml_lint', require: false
  gem 'rubocop', require: false
end
