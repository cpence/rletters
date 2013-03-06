source 'http://rubygems.org'

# Rails
gem 'rails', '~> 3.0'
gem 'rails-i18n', '= 0.7.2'

# Deployment and server tools
gem 'capistrano', :require => false
gem 'capistrano-maintenance', :require => false
gem 'delayed_job', '~> 3.0', '>= 3.0.1'
gem 'delayed_job_active_record'
gem 'daemons', :require => false
gem 'whenever', :require => false
gem 'airbrake', :require => false

# Database and related tools
gem 'pg'
gem 'activerecord-import'
gem 'seed-fu', '>= 2.1.0'
gem 'rails-settings-cached', '0.2.4' # 0.3.0 for Rails 4

# User authentication and administration
gem 'devise'
gem 'devise-i18n'
gem 'activeadmin'

# Support for file attachments and exporting
gem 'paperclip', '~> 3.0'
gem 'paperclip-meta'
gem 'rubyzip'
gem 'rsolr', '>= 1.0.7'
gem 'rsolr-ext'
gem 'marc'
gem 'rdf', '>= 0.3.5'
gem 'rdf-rdfxml'
gem 'rdf-n3'

# Support for citation processing
gem 'unicode', '>= 0.4.3.1.pre1'
gem 'latex-decode', '>= 0.0.11'
gem 'bibtex-ruby', '~> 2.0', :require => 'bibtex'
gem 'citeproc-ruby', '>= 0.0.4'

# Some templating engines that are required even when we're not
# building the assets
gem 'haml'
gem 'haml-rails'
gem 'kramdown'

group :assets do
  gem 'coffee-rails'
  gem 'sass-rails'
  
  gem 'jquery-rails', '= 2.2.1'
  gem 'jquery_mobile_rails', '= 1.3.0'

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
  gem 'coveralls', :require => false
end

group :test do
  gem 'fuubar'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'webrat'
  gem 'vcr', :require => false
  gem 'webmock', :require => false
  gem 'nokogiri', :require => false
end

group :development do
  gem 'yard', :require => false
  gem 'magic_encoding', :require => false
end
