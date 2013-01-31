#!/usr/bin/env rake

require File.expand_path('../config/application', __FILE__)
RLetters::Application.load_tasks

# Start and stop the Solr server when we run RSpec
Rake::Task['spec'].enhance [ 'solr:start' ]
Rake::Task['spec'].enhance do
  Rake::Task['solr:stop'].invoke
end
