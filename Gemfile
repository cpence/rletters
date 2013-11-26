source 'https://rubygems.org'

# Rails
gem 'rails', '~> 4.0'
gem 'rails-i18n', '= 4.0.0'

# Database and related tools
gem 'pg', platform: [:ruby, :mswin, :mingw]
gem 'activerecord-jdbcpostgresql-adapter', platform: :jruby
gem 'activerecord-import', '>= 0.4.0'
gem 'closure_tree'
gem 'trim_blobs'
gem 'addressable'

# Job scheduling
gem 'resque'
gem 'resque-scheduler', '~> 2.2.0', require: 'resque_scheduler'
gem 'resque_mailer'

# User authentication and administration
gem 'devise'
gem 'devise-i18n'
gem 'devise-async'
gem 'activeadmin', github: 'gregbell/active_admin'
gem 'activeadmin-sortable-tree', :github => 'nebirhos/activeadmin-sortable-tree'
gem 'druthers'

# Textual analysis
gem 'rsolr', '>= 1.0.7'
gem 'rsolr-ext'
gem 'stanford-core-nlp'

# Citation processing
gem 'bibtex-ruby', '~> 2.0', require: 'bibtex'
gem 'citeproc-ruby', '>= 0.0.4'

# Support for file attachments and exporting
gem 'paperclip', '~> 3.0'
gem 'paperclip_database', '>= 2.2.0'
gem 'rubyzip', '>= 1.1.0', require: 'zip'
gem 'marc'
gem 'rdf', '>= 0.3.5'
gem 'rdf-n3'

# Asset tools and template generators
gem 'haml'
gem 'haml-rails'
gem 'kramdown'
gem 'nokogiri'
gem 'active_model_serializers'

gem 'jquery-rails'
gem 'compass-rails'
gem 'sass-rails'
gem 'foundation-rails'
gem 'simple_form'

gem 'yui-compressor'

# Testing
group :test, :development do
  gem 'rspec-rails'
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'capybara', require: false
  gem 'poltergeist', require: false
  gem 'database_cleaner'

  gem 'factory_girl_rails'
  gem 'webmock', require: false
  gem 'resque_spec'
  gem 'mock_redis'

  gem 'coveralls', require: false
end

# Deployment gems
group :production do
  gem 'unicorn', require: false, platform: [:ruby, :mswin, :mingw]
  gem 'puma', require: false, platform: :jruby
  gem 'resque-pool', require: false, platform: [:ruby, :mswin, :mingw]
  gem 'airbrake', require: false
end
