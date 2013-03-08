# -*- encoding : utf-8 -*-
# 
# = Capistrano unicorn.rb task
#
# Provides a couple of tasks for creating the unicorn.rb 
# configuration file dynamically when deploy:setup is run.
#

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :deploy do

    namespace :unicorn do

      desc <<-DESC
        Creates the unicorn.rb configuration file in shared path.

        By default, this task uses a template unless a template \
        called unicorn.rb.erb is found either in :template_dir \
        or /config/deploy folders.

        When this recipe is loaded, unicorn:setup is automatically configured \
        to be invoked after deploy:setup. You can skip this task setting \
        the variable :skip_unicorn_setup to true.
      DESC
      task :setup, :except => { :no_release => true } do

        default_template = <<-EOF
        listen 2007 # by default Unicorn listens on port 8080
        worker_processes 2 # this should be >= nr_cpus
        pid "<%= deploy_to %>/tmp/pids/unicorn.pid"
        stderr_path "<%= deploy_to %>/log/unicorn.log"
        stdout_path "<%= deploy_to %>/log/unicorn.log"
        EOF

        location = fetch(:template_dir, "config/deploy") + '/unicorn.rb.erb'
        template = File.file?(location) ? File.read(location) : default_template

        config = ERB.new(template)

        run "mkdir -p #{shared_path}/config" 
        put config.result(binding), "#{shared_path}/config/unicorn.rb"
      end

      desc <<-DESC
        [internal] Updates the symlink for database.yml file to the just deployed release.
      DESC
      task :symlink, :except => { :no_release => true } do
        run "ln -nfs #{shared_path}/config/unicorn.rb #{release_path}/config/unicorn.rb" 
      end

    end

    after "deploy:setup", "deploy:unicorn:setup"   unless fetch(:skip_unicorn_setup, false)
    after "deploy:assets:symlink", "deploy:unicorn:symlink"

  end

end
