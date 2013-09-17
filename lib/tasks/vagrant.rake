# -*- encoding : utf-8 -*-
# Tasks for dealing with our deployment testing via Vagrant
require 'fileutils'

namespace :vagrant do
  desc 'Download the required Vagrant image (warning: takes a while)'
  task :download do
    system('vagrant box add pl_centos64_rletters http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box',
           chdir: Rails.root.join('deploy'))
  end

  desc 'Bring up a new vagrant VM'
  task :up do
    system('vagrant up',
           chdir: Rails.root.join('deploy'))

  end

  desc 'Bring down the vagrant VM'
  task :down do
    system('vagrant halt',
           chdir: Rails.root.join('deploy'))
    system('vagrant destroy -f',
           chdir: Rails.root.join('deploy'))

    # Remove all the password files
    FileUtils.rm_f Rails.root.join('deploy', 'roles', 'db', 'files', 'db_192.168.111.222_pass')
    FileUtils.rm_f Rails.root.join('deploy', 'roles', 'solr', 'files', 'tomcat_192.168.111.222_pass')
    FileUtils.rm_f Rails.root.join('deploy', 'roles', 'web', 'files', 'deploy_192.168.111.222_pass')
  end
end
