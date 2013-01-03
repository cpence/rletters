# 
# Capistrano Task for symlinking the config/initializers/secret_token.rb
#
Capistrano::Configuration.instance(true).load do
  namespace :deploy do
    desc "Moves and replaces the secret-token if missing in shared directory"
    task :symlink_secret, :roles => :app, :except => { :no_release => true } do 
      filename       = 'secret_token.rb'
      release_secret = "#{release_path}/config/initializers/#{filename}"
      shared_secret  = "#{shared_path}/config/#{filename}"
      
      if capture("[ -f #{shared_secret} ] || echo missing").start_with?('missing')
        run "cd #{current_path} && bundle exec rake secret:replace", :env => { :RAILS_ENV => rails_env }
        run "mkdir -p #{shared_path}/config; mv #{release_secret} #{shared_secret}"
      end
      
      # symlink secret token
      run "ln -nfs #{shared_secret} #{release_secret}"
    end
  end
  
  after "deploy:update", "deploy:symlink_secret"
end
