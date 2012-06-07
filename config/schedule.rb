# -*- encoding : utf-8 -*-

set :output, {:standard => 'log/cron.log', :error => 'log/cron_error.log'}
env :PATH, "#{YAML.load_file(File.expand_path('../app_config.yml', __FILE__))['all_environments']['ruby_path']}:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"
env :MAILTO, "#{YAML.load_file(File.expand_path('../app_config.yml', __FILE__))['all_environments']['app_email']}"


job_type :env_command, "cd :path && RAILS_ENV=:environment bundle exec :task :output"

every 1.hours do
  rake "db:sessions:expire"
  rake "db:downloads:expire"
end

every :reboot do
  env_command "script/delayed_job restart"
end

