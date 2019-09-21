# config valid for current version and patch releases of Capistrano
lock '~> 3.11.1'

set :application, 'rletters'
set :repo_url, 'https://github.com/rletters/rletters.git'
set :deploy_to, "/var/rletters"

set :migration_role, :app

append :linked_dirs, '.bundle', 'tmp/pids', 'tmp/cache', 'tmp/sockets',
                     'tmp/storage'
# append :linked_files, "config/database.yml"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
