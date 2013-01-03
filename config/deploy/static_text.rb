# -*- encoding : utf-8 -*-

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :rletters do
    
    desc <<-DESC
      Sync the static_text directory
      
      This task updates the Markdown files located in the static_text
      directory (if new ones are available) and links them into the release
      path.
    DESC
    task :copy_static_text do
      run "mkdir -p #{shared_path}/static_text"
      
      Dir.glob('app/views/static/*.markdown.dist') do |file|
        md_file = File.basename(file, '.dist')
        
        unless remote_file_exists? "#{shared_path}/static_text/#{md_file}"
          run "cp #{release_path}/#{file} #{shared_path}/static_text/#{md_file}"
        end
      end
      run "ln -sf #{shared_path}/static_text/* #{release_path}/app/views/static/"
    end
    
    before "deploy:assets:symlink", "rletters:copy_static_text"
    
  end
  
end
