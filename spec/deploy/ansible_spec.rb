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

  describe 'db role' do
    describe 'main.yml' do
      it 'successfully installs postgresql' do
        expect(vagrant_ssh('which psql')).to eq("/usr/bin/psql\n")
      end

      it 'creates the database password file' do
        file_path = Rails.root.join('deploy', 'roles', 'db', 'files', 'db_192.168.111.222_pass')
        expect(File.exist?(file_path)).to be_true
      end

      it 'creates the database and user' do
        file_path = Rails.root.join('deploy', 'roles', 'db', 'files', 'db_192.168.111.222_pass')
        db_password = IO.read(file_path)

        # Set the password on the server for passwordless authentication
        vagrant_ssh("echo '*:*:*:*:#{db_password}' > ~/.pgpass")
        vagrant_ssh('chmod 0600 ~/.pgpass')

        # Make sure the database exists and the user can connect
        expect(vagrant_ssh('psql -d rletters_production -U rletters_postgresql -c \\\\\\\\list')).to match(/ rletters_production /)

        # Clean up the authentication file
        vagrant_ssh('rm ~/.pgpass')
      end

      it 'does not make the PostgreSQL server publically accessible' do
        # Since the web server and DB server are both on the same host, the
        # scripts should *not* open port 5432 through iptables.
        vagrant_check_port_closed(5432)
      end
    end
  end

  describe 'solr role' do
    describe 'tomcat.yml' do
      it 'starts the Tomcat server' do
        expect(vagrant_ssh('/etc/init.d/tomcat status')).to include('Tomcat is running')
      end

      it 'makes Tomcat functional' do
        expect(vagrant_ssh('wget -q -O- http://localhost:8080')).to include('<title>Apache Tomcat/7')
      end

      it 'creates the Tomcat password file' do
        file_path = Rails.root.join('deploy', 'roles', 'solr', 'files', 'tomcat_192.168.111.222_pass')
        expect(File.exist?(file_path)).to be_true
      end

      it 'configures the Tomcat administration GUI' do
        file_path = Rails.root.join('deploy', 'roles', 'solr', 'files', 'tomcat_192.168.111.222_pass')
        tomcat_password = IO.read(file_path).sub("\n", '')

        expect(vagrant_ssh("wget -q -O- http://rletters_tomcat:#{tomcat_password}@localhost:8080/manager/html")).to include('<title>/manager</title>')
      end

      it 'does not make the Tomcat server publically accessible' do
        # Since the web server and Solr server are both on the same host, the
        # scripts should *not* open port 8080 through iptables.
        vagrant_check_port_closed(8080)
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
