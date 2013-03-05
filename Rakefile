#!/usr/bin/env rake

require File.expand_path('../config/application', __FILE__)
RLetters::Application.load_tasks

# Start and stop the Solr server around running the built-in Rails server
task :server => :environment do
  Rake::Task['solr:start'].invoke
  system 'rails server'
  Rake::Task['solr:stop'].invoke
end
