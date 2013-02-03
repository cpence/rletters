# -*- encoding : utf-8 -*-

Capistrano::Configuration.instance.load do

  # Run seed_fu on the production server.  This should probably only be done
  # manually, for safety's sake.
  namespace :deploy do
    desc "reload the database with seed data"
    task :seed do
      run "cd #{current_path}; bundle exec rake db:seed_fu RAILS_ENV=#{rails_env}"
    end
  end

end
