# -*- encoding : utf-8 -*-

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  # Touch the restart file when we restart the application.  You can comment
  # out the reference to this file in deploy.rb if you aren't using
  # Passenger.
  namespace :deploy do
    task :start do ; end
    task :stop do ; end
    task :restart, roles: :app, except: { no_release: true } do
      run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    end
  end

end
