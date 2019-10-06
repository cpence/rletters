namespace :deploy do

  desc 'Runs rake db:seed if seeds are set'
  task :seed => [:set_rails_env] do
    on fetch(:seed_servers) do
      conditionally_seed = fetch(:conditionally_seed)
      info '[deploy:seed] Checking changes in db' if conditionally_seed
      if conditionally_seed && test(:diff, "-qr #{release_path}/db #{current_path}/db")
        info '[deploy:seed] Skip `deploy:seed` (nothing changed in db)'
      else
        info '[deploy:seed] Run `rake db:seed`'
        # NOTE: We access instance variable since the accessor was only added recently. Once capistrano-rails depends on rake 11+, we can revert the following line
        invoke :'deploy:seeding' unless Rake::Task[:'deploy:seeding'].instance_variable_get(:@already_invoked)
      end
    end
  end

  desc 'Runs rake db:seed'
  task seeding: [:set_rails_env] do
    on fetch(:seed_servers) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'db:seed'
        end
      end
    end
  end

  after 'deploy:updated', 'deploy:seed'
end

namespace :load do
  task :defaults do
    set :conditionally_seed, fetch(:conditionally_seed, false)
    set :seed_role, fetch(:seed_role, :db)
    set :seed_servers, -> { primary(fetch(:seed_role)) }
  end
end
