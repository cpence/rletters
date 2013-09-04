# -*- encoding : utf-8 -*-
# Tasks for dealing with our deployment testing via Vagrant

namespace :vagrant do
  desc 'Download the required Vagrant image (warning: takes a while)'
  task :download do
    system('vagrant box add pl_centos64_rletters http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box')
  end

  desc 'Bring up a new vagrant VM'
  task :up do
    system('vagrant up')
  end

  desc 'Bring down the vagrant VM'
  task :down do
    system('vagrant halt')
    system('vagrant destroy -f')
  end
end
