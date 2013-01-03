# -*- encoding : utf-8 -*-

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :rletters do
    
    desc <<-DESC
      Link the static_assets folder (in shared) into the public directory
      
      This file will copy the sample static_assets in the contrib directory
      if this is a new installation.
    DESC
    task :copy_static_assets do
      unless remote_file_exists? "#{shared_path}/static_assets/favicon.ico"
        run "cp -R #{release_path}/contrib/static_assets #{shared_path}"
      end
      
      run "ln -s #{shared_path}/static_assets #{release_path}/public/static_assets"
    end
    
    after "deploy:assets:symlink", "rletters:copy_static_assets"
    
  end
  
end
