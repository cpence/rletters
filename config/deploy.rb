lock '~> 3.11.1'

set :application, 'rletters'
set :repo_url, 'https://github.com/rletters/rletters.git'
set :branch, 'capistrano'
set :deploy_to, '/var/rletters'

# Preserve all installed packages (Bundler/yarn) and all of the stuff that's
# automatically spit out by Rails.
append :linked_dirs, '.bundle', 'node_modules',
                     'tmp/pids', 'tmp/cache', 'tmp/sockets', 'tmp/storage'

# Our environment-variable configuration file
append :linked_files, '.env'

# Enable log output if needed for debugging failures
set :format_options, log_file: nil
# set :format_options, log_file: 'capistrano-debug.log'

# Do DB migrations and seeds only on the primary web server
set :migration_role, :web
set :seed_role, :web

# Restart services after deployment
namespace :deploy do
  desc 'Reload or restart relevant systemd services'
  task :restart_services do
    on roles(:web) do
      execute 'sudo systemctl reload-or-restart rletters-puma'
    end
    on roles(:worker) do
      execute 'sudo systemctl reload-or-restart rletters-analysis'
    end
    on primary(:worker) do
      execute 'sudo systemctl reload-or-restart rletters-maintenance'
    end
  end

  after :publishing, :restart_services
end
