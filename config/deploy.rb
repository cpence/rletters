lock '~> 3.12'

set :application, 'rletters'
set :repo_url, 'https://github.com/rletters/rletters.git'
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

# Compile assets on the worker, because it sends emails
set :assets_roles, [:web, :worker]

# Don't keep too many versions of old assets
set :keep_assets, 3

# Fix bundler configuration for the latest version (>= 2.1)
set :bundle_flags, '--quiet'
set :bundle_path, nil
set :bundle_without, nil

namespace :deploy do
  desc 'Configure local bundler options'
  task :config_bundler do
    on roles(/.*/) do
      execute 'bundle config --local deployment true'
      execute 'bundle config --local without "development test"'
      execute "bundle config --local path #{shared_path.join('bundle')}"
    end
  end
end

before 'bundler:install', 'deploy:config_bundler'

# Restart services after deployment
def reload_or_start(service)
  status = capture("sudo systemctl is-active #{service}",
                   raise_on_non_zero_exit: false)
  if status.start_with?('active')
    execute "sudo systemctl reload #{service}"
  else
    execute "sudo systemctl restart #{service}"
  end
end

namespace :deploy do
  desc 'Reload or restart relevant systemd services'
  task :restart_services do
    on roles(:web) do
      reload_or_start('rletters-puma')
    end
    on roles(:worker) do
      reload_or_start('rletters-analysis')
    end
    on primary(:worker) do
      reload_or_start('rletters-maintenance')
    end
  end

  after :publishing, :restart_services
end
