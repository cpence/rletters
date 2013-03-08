# -*- encoding : utf-8 -*-

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

Capistrano::Configuration.instance.load do

  # Touch the restart file when we restart the application.  You can comment
  # out the reference to this file in deploy.rb if you aren't using
  # Unicorn.
  namespace :deploy do
    task :start do ; end
    task :stop do ; end
    task :restart, :roles => :app, :except => { :no_release => true } do
      #if remote_file_exists?("#{shared_path}/pids/unicorn.pid")
      #  run "cd #{shared_path}/pids && kill -s USR2 `cat unicorn.pid`"
      #end
    end
  end

end
