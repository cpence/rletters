source 'https://rubygems.org'

# Rails
gem 'rails', '~> 4.0'
gem 'rails-i18n', '= 4.0.0.pre2'

# Database and related tools
group :production, :development do
  gem 'pg', platform: [:ruby, :mswin, :mingw]
  gem 'activerecord-jdbcpostgresql-adapter', platform: :jruby
end
group :test do
  gem 'sqlite3', platform: [:ruby, :mswin, :mingw]
  gem 'activerecord-jdbcsqlite3-adapter', platform: :jruby
end
gem 'activerecord-import', '>= 0.4.0'
gem 'trim_blobs'
gem 'addressable'

# Job scheduling
gem 'resque'
gem 'resque-scheduler', require: 'resque_scheduler'

# User authentication and administration
gem 'devise'
gem 'devise-i18n'
gem 'activeadmin', github: 'gregbell/active_admin'
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
gem 'paperclip_database'
# This release hasn't been cut yet; waiting on it
# gem 'rubyzip', '>= 1.1.0'
gem 'rubyzip', github: 'rubyzip/rubyzip', require: 'zip'
gem 'marc'
gem 'rdf', '>= 0.3.5'
gem 'rdf-n3'

# Asset tools and template generators
gem 'haml'
gem 'haml-rails'
gem 'kramdown'
gem 'nokogiri'
gem 'sass-rails'

gem 'jquery-rails', '= 3.0.4'
gem 'jquery_mobile_rails', '= 1.3.2'

gem 'yui-compressor'

# Testing
group :test, :development do
  gem 'rspec-rails'
end

group :test do
  gem 'fuubar'
  gem 'factory_girl_rails'
  gem 'rspec-html-matchers'
  gem 'vcr', require: false
  gem 'webmock', require: false
  gem 'resque_spec'
  gem 'coveralls', require: false
end

# Deployment gems
group :production do
  gem 'unicorn', require: false, platform: [:ruby, :mswin, :mingw]
  gem 'puma', require: false, platform: :jruby
  gem 'resque-pool', require: false, platform: [:ruby, :mswin, :mingw]
  gem 'airbrake', require: false
end
