# -*- encoding : utf-8 -*-
# 
# = Capistrano configuration task for RLetters
#
# Provides a couple of tasks for creating the app_config.yml 
# configuration file dynamically when deploy:setup is run.
#
# 
# == Usage
# 
# Include this file in your <tt>deploy.rb</tt> configuration file.
# Assuming you saved this recipe as app_config.rb:
# 
#   require "app_config"
# 
# Now, when <tt>deploy:setup</tt> is called, this script will automatically
# create the <tt>app_config.yml</tt> file in the shared folder.
# Each time you run a deploy, this script will also create a symlink
# from your application <tt>config/app_config.yml</tt> pointing to the shared 
# configuration file. 
# 
# == Custom template
# 
# The configuration will be loaded from <tt>config/deploy/app_config.yml.erb</tt>.
# Because this is an Erb template, you can place variables and Ruby scripts
# within the file.
#

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :deploy do

    namespace :config do

      desc <<-DESC
        Creates the app_config.yml configuration file in shared path.

        This task requires a template in the \
        /config/deploy folder.

        When this recipe is loaded, config:setup is automatically configured \
        to be invoked after deploy:setup. You can skip this task setting \
        the variable :skip_config_setup to true. This is especially useful \ 
        if you are using this recipe in combination with \
        capistrano-ext/multistaging to avoid multiple config:setup calls \ 
        when running deploy:setup for all stages one by one.
      DESC
      task :setup, :except => { :no_release => true } do

        location = 'config/deploy/app_config.yml.erb'
        template = File.read(location)

        config = ERB.new(template)

        run "mkdir -p #{shared_path}/config" 
        put config.result(binding), "#{shared_path}/config/app_config.yml"
      end

      desc <<-DESC
        [internal] Updates the symlink for app_config.yml file to the just deployed release.
      DESC
      task :symlink, :except => { :no_release => true } do
        run "ln -nfs #{shared_path}/config/app_config.yml #{release_path}/config/app_config.yml" 
      end

    end

    after "deploy:setup", "deploy:config:setup" unless fetch(:skip_config_setup, false)
    after "deploy:assets:symlink", "deploy:config:symlink"

  end

end
