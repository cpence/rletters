# This is our configuration for deploying to a Vagrant virtual machine on
# localhost for testing. You should ignore this.
server 'localhost', user: 'rletters', roles: %w{web worker}, primary: true

set :ssh_options, {
  keys: %w{../ansible/backup/deployment-key-vagrant},
  port: 2222,
  forward_agent: false
}

set :stage, :production
set :rails_env, 'production'
