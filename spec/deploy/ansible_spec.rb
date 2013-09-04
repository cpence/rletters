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
    end
  end
end
