# config valid for current version and patch releases of Capistrano
lock '~> 3.11.1'

set :application, 'rletters'
set :repo_url, 'https://github.com/rletters/rletters.git'
set :branch, 'capistrano'
set :deploy_to, '/var/rletters'

set :migration_role, :app

# Preserve all installed packages (Bundler/yarn) and all of the stuff that's
# automatically spit out by Rails.
append :linked_dirs, '.bundle', 'node_modules',
                     'tmp/pids', 'tmp/cache', 'tmp/sockets', 'tmp/storage'

# Our environment-variable configuration file
append :linked_files, '.env'

# Enable log output if needed for debugging failures
set :format_options, log_file: nil
# set :format_options, log_file: 'capistrano-debug.log'
