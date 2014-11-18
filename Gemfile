source 'https://rubygems.org'

# Rails
gem 'rails', '~> 4.0'

# Database and related tools
gem 'pg'
gem 'activerecord-import', '>= 0.4.0'
gem 'foreigner'
gem 'closure_tree'
gem 'validate_url'
gem 'addressable'

# Job scheduling
gem 'resque'
gem 'resque-status'
gem 'resque-scheduler'
gem 'resque_mailer'

# User authentication and administration
gem 'devise'
gem 'devise-i18n'
gem 'devise-async'
gem 'activeadmin', github: 'activeadmin'
gem 'activeadmin-sortable-tree', github: 'nebirhos/activeadmin-sortable-tree'
gem 'druthers'

# Internationalization
gem 'rails-i18n', '= 4.0.2'
gem 'i18n-js-pika', '>= 3.0.0.rc1', require: 'i18n-js'
gem 'http_accept_language'

# Textual analysis
gem 'rsolr', '>= 1.0.7'
gem 'rsolr-ext'
gem 'cheetah'
gem 'distribution'
gem 'fast-stemmer'
gem 'd3_rails'

# Citation processing
gem 'bibtex-ruby', require: 'bibtex'
gem 'citeproc-ruby', '~> 1.0'
gem 'csl-styles'

# Support for file attachments and exporting
gem 'paperclip', '>= 4.2.0'
gem 'paperclip_database', '>= 2.2.0'
gem 'rubyzip', '>= 1.1.0', require: 'zip'
gem 'marc'
gem 'rdf', '>= 0.3.5'
gem 'rdf-n3'

# Asset tools and template generators
gem 'draper'
gem 'haml'
gem 'haml-rails'
gem 'kramdown'
gem 'nokogiri'
gem 'rabl'

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'sass-rails', '>= 4.0.3'
gem 'bootstrap-sass'
gem 'simple_form', '>= 3.1.0.rc1'

gem 'uglifier'
gem 'roadie-rails'

# Testing
group :test, :development do
  gem 'rspec-rails', '~> 3'

  # Some of these need to be here to enable proper use of the development
  # server, including mailer previews
  gem 'mock_redis'
  gem 'factory_girl_rails'
end

group :test do
  gem 'cucumber-rails', '>= 1.4.2', require: false
  gem 'capybara', require: false
  gem 'poltergeist', require: false
  gem 'database_cleaner'

  gem 'webmock', require: false

  gem 'coveralls', require: false
end

# Deployment gems
group :production do
  gem 'unicorn', require: false
  gem 'resque-pool', require: false
  gem 'airbrake', require: false
end
