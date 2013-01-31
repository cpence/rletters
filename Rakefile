#!/usr/bin/env rake

require File.expand_path('../config/application', __FILE__)
RLetters::Application.load_tasks

# Start and stop the Solr server when we run RSpec
Rake::Task['spec'].enhance [ 'solr:start' ]
Rake::Task['spec'].enhance do
  Rake::Task['solr:stop'].invoke
end

# Don't prep the test database; since it's in-memory we have to do that in
# spec_helper.rb
Rake::Task['spec'].prerequisites.delete('db:test:prepare')
