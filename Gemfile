source 'http://rubygems.org'

gem 'rails', '~> 3.0'
gem 'rails-i18n', '= 0.4.0'

gem 'jruby-openssl', :platforms => :jruby
gem 'activerecord-import'

gem 'capistrano'
gem 'delayed_job', '~> 3.0', '>= 3.0.1'
gem 'delayed_job_active_record'
gem 'airbrake'

gem 'rpx_now'
gem 'email_validator'

gem 'rubyzip'
gem 'rsolr', '>= 1.0.7'
gem 'rsolr-ext'
gem 'marc'
gem 'rdf', '>= 0.3.5'
gem 'rdf-rdfxml', :platforms => [ :ruby, :mswin, :mingw ]
gem 'rdf-n3'
gem 'fastercsv', :platforms => [ :ruby_18, :mingw_18, :jruby ]

gem 'latex-decode', '>= 0.0.11'
gem 'bibtex-ruby', '~> 2.0', :require => 'bibtex'
gem 'citeproc-ruby', '>= 0.0.4'

gem 'haml'
gem 'haml-rails'
gem 'kramdown'

gem 'jquery-rails', '= 1.0.18'
gem 'jquery_mobile-rails', '= 1.1.0'

group :production do
  gem 'mysql2', :platforms => [ :ruby, :mswin, :mingw ]
  gem 'activerecord-jdbcmysql-adapter', :platforms => :jruby

  gem 'daemons', :require => false
  gem 'whenever', :require => false
end

group :assets do
  gem 'sass-rails'
  gem 'uglifier'
  
  # Uglifier needs an ExecJS runtime, but we don't need to
  # require it everywhere.
  gem 'execjs', :require => false
  gem 'therubyracer', :require => false, 
    :platforms => [ :ruby, :mswin, :mingw ]
  gem 'therubyrhino', :require => false, 
    :platforms => :jruby
end

group :test, :development do
  gem 'rspec-rails'

  gem 'sqlite3'
  gem 'activerecord-jdbcsqlite3-adapter', :platforms => :jruby
end

group :test do
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'webrat'
  gem 'webmock', :require => false
  gem 'nokogiri'
end

group :development do
  gem 'yard'
  gem 'yard-rails'

  gem 'magic_encoding', :require => false

  # SimpleCov requires manual intervention, don't run it in CI. Also,
  # it only runs on Ruby 1.9.
  gem 'simplecov', '>= 0.4.0', :require => false,
    :platforms => [ :ruby_19, :mingw_19 ]
end
