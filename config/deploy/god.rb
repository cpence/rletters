# -*- encoding : utf-8 -*-

Capistrano::Configuration.instance.load do

  # Handle starting and stopping God for this application (use a specific
  # init script, and start it up via Bundler; see config/god/init_script*)
  namespace :god do
    desc "start God"
    task :start do
      if remote_file_exists? "/etc/init.d/god-#{application}"
        run "sudo /etc/init.d/god-#{application} start"
      else
        logger.log Capistrano::Logger::IMPORTANT, "Init script for God not found on server; see config/god/init_script*"
      end
    end

    desc "stop God"
    task :stop do
      if remote_file_exists? "/etc/init.d/god-#{application}"
        run "sudo /etc/init.d/god-#{application} stop"
      else
        logger.log Capistrano::Logger::IMPORTANT, "Init script for God not found on server; see config/god/init_script*"
      end
    end

    desc "restart God"
    task :restart do
      if remote_file_exists? "/etc/init.d/god-#{application}"
        run "sudo /etc/init.d/god-#{application} restart"
      else
        logger.log Capistrano::Logger::IMPORTANT, "Init script for God not found on server; see config/god/init_script*"
      end
    end

    desc "reload God services"
    task :reload do
      if remote_file_exists? "/etc/init.d/god-#{application}"
        run "sudo /etc/init.d/god-#{application} reload"
      else
        logger.log Capistrano::Logger::IMPORTANT, "Init script for God not found on server; see config/god/init_script*"
      end
    end

    after "deploy:start", "god:start"
    after "deploy:stop", "god:stop"
    after "deploy:restart", "god:reload"

  end

end
