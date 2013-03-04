source 'http://rubygems.org'

gem 'safe_yaml', '>= 0.6.2'

gem 'rails', '~> 3.0'
gem 'rails-i18n', '= 0.7.1'

gem 'capistrano'
gem 'capistrano-maintenance'
gem 'delayed_job', '~> 3.0', '>= 3.0.1'
gem 'delayed_job_active_record'
gem 'airbrake'

gem 'pg'
gem 'activerecord-import'
gem 'seed-fu', '>= 2.1.0'
gem 'paperclip', '~> 3.0'
gem 'paperclip-meta'

gem 'rails-settings-cached', '0.2.4' # 0.3.0 for Rails 4

gem 'devise'
gem 'devise-i18n'
gem 'activeadmin'

gem 'rubyzip'
gem 'rsolr', '>= 1.0.7'
gem 'rsolr-ext'
gem 'marc'
gem 'rdf', '>= 0.3.5'
gem 'rdf-rdfxml', :platforms => [ :ruby, :mswin, :mingw ]
gem 'rdf-n3'

gem 'unicode', '>= 0.4.3.1.pre1'
gem 'latex-decode', '>= 0.0.11'
gem 'bibtex-ruby', '~> 2.0', :require => 'bibtex'
gem 'citeproc-ruby', '>= 0.0.4'

gem 'haml'
gem 'haml-rails'
gem 'kramdown'

group :production do
  gem 'daemons', :require => false
  gem 'whenever', :require => false
end

group :assets do
  gem 'sass-rails'
  
  gem 'coffee-rails'
  
  gem 'jquery-rails', '= 2.1.3'
  gem 'jquery_mobile_rails', '= 1.2.0'

  unless ENV['TRAVIS']
    gem 'uglifier'
  
    # Uglifier needs an ExecJS runtime, but we don't need to
    # require it everywhere.
    gem 'execjs', :require => false
    gem 'therubyracer', '>= 0.11.0beta5', :require => false
    gem 'libv8', '>= 3.11.8', :require => false
  end
end

group :test, :development do
  gem 'rspec-rails'
end

group :test do
  gem 'fuubar'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'webrat'
  gem 'webmock', :require => false
  gem 'nokogiri'
end

group :development do
  gem 'yard'

  gem 'magic_encoding', :require => false

  # SimpleCov requires manual intervention, don't load it in CI.
  gem 'simplecov', '>= 0.4.0', :require => false
end
