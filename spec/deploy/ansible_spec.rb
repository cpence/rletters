# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'Ansible provisioning', :deploy do
  before(:all) do
    system("cd #{Rails.root} && rake vagrant:up")
    system("cd #{Rails.root.join('deploy')} && ansible-playbook -i hosts.testing site.yml")
  end

  after(:all) do
    system("cd #{Rails.root} && rake vagrant:down")
  end

  describe 'common role' do
    describe 'ntp.yml' do
      it 'starts the NTP service' do
        expect(vagrant_ssh('/etc/init.d/ntpd status')).to match(/ntpd .* is running\.\.\./)
      end

      it 'does not make the NTP daemon publically accessible' do
        vagrant_check_port_closed(123)
      end

      it 'synchronizes to a time server' do
        expect(vagrant_ssh("ntpq -np | grep -E '((25[0-5]|2[0-4][0-9]|[1]?[1-9][0-9]?).){3}(25[0-5]|2[0-4][0-9]|[1]?[1-9]?[0-9])'")).to_not be_empty
      end
    end
  end

  describe 'web role' do
    describe 'ruby.yml' do
      it 'successfully installs ruby' do
        expect(vagrant_ssh('which ruby')).to eq("/usr/local/bin/ruby\n")
      end

      it 'successfully installs gem' do
        expect(vagrant_ssh('which gem')).to eq("/usr/local/bin/gem\n")
      end

      it 'successfully installs bundler' do
        expect(vagrant_ssh('which bundle')).to eq("/usr/local/bin/bundle\n")
      end
    end
  end
end
