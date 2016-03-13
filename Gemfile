source 'https://rubygems.org'

# Rails
gem 'rake', '~> 10.0' # FIXME: This is a bug in YARD

gem 'rails', '~> 5.0.0.beta3'
gem 'puma'

# Twelve factor app glue
gem 'dotenv-rails'
gem 'lograge'

# Database and related tools
gem 'pg'
gem 'que'
gem 'closure_tree'
gem 'validate_url'
gem 'virtus'
gem 'addressable'

# User authentication and administration
gem 'devise', '~> 4.0.0.rc1'
gem 'devise-i18n'
gem 'setler'

# Internationalization
gem 'rails-i18n', '~> 5.0.0.beta3'

# Textual analysis
gem 'rsolr', '>= 1.0.7'
gem 'rsolr-ext'
gem 'cheetah'
gem 'distribution'
gem 'fast-stemmer'

# Citation processing
gem 'bibtex-ruby', require: 'bibtex'
gem 'citeproc-ruby', '~> 1.0'
gem 'csl-styles'

# Support for file attachments and exporting
gem 'paperclip', '>= 4.2.0'
gem 'paperclip_database', github: 'pwnall/paperclip_database', branch: 'rails5'
gem 'rubyzip', '>= 1.1.0', require: 'zip'
gem 'marc'
gem 'rdf', '>= 0.3.5'
gem 'rdf-vocab'
gem 'rdf-n3'

# Visualization
gem 'prawn'
gem 'chunky_png'
gem 'mini_magick'

# Asset tools and template generators
gem 'haml'
gem 'haml-rails'
gem 'sass-rails', '~> 5.0'
gem 'kramdown'
gem 'nokogiri'

gem 'simple_form', '>= 3.1.0.rc1'

gem 'uglifier', '>= 1.3.0'
gem 'multi_mail'
gem 'roadie-rails', '>= 1.1.1'

# Testing
group :test, :development do
  gem 'rspec-rails', '~> 3.5.0.beta'
  gem 'rspec-activejob', require: false
  gem 'rails-controller-testing'

  gem 'factory_girl_rails'
end

group :test do
  gem 'capybara', require: false
  # gem 'capybara-slow_finder_errors'
  gem 'capybara-webkit'

  gem 'launchy'
  gem 'database_cleaner'

  gem 'webmock', '>= 1.22.6', require: false

  gem 'pdf-inspector', require: false

  gem 'simplecov', require: false
  gem 'codeclimate-test-reporter', require: false
end
