# -*- encoding : utf-8 -*-

# Start and stop the Solr server when we run RSpec
Rake::Task['spec'].enhance [ 'solr:start' ]
Rake::Task['spec'].enhance do
  Rake::Task['solr:stop'].invoke
end

# Task for SimpleCov
namespace :spec do
  desc "Run all specs in spec directory with code coverage"
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task['spec'].invoke
  end
end

# Don't prep the test database; since it's in-memory we have to do that in
# spec_helper.rb
Rake::Task['spec'].prerequisites.delete('db:test:prepare')

# Clear out unused RSpec tasks
Rake::Task['spec:mailers'].clear
Rake::Task['spec:rcov'].clear
Rake::Task['spec:requests'].clear

# Clear out the old 'test' tasks
Rake::Task['test:recent'].clear
Rake::Task['test:single'].clear
Rake::Task['test:uncommitted'].clear
Rake::Task['test'].clear
