# -*- encoding : utf-8 -*-

# Start and stop the Solr server when we run RSpec
Rake::Task['spec'].enhance [ 'solr:start' ]
Rake::Task['spec'].enhance do
  Rake::Task['solr:stop'].invoke
end

# Clear out unused RSpec tasks
Rake::Task['spec:mailers'].clear
Rake::Task['spec:rcov'].clear
Rake::Task['spec:requests'].clear

# Clear out the old 'test' tasks
Rake::Task['test:recent'].clear
Rake::Task['test:single'].clear
Rake::Task['test:uncommitted'].clear
Rake::Task['test'].clear
