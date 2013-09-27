# -*- encoding : utf-8 -*-
ENV['RAILS_ENV'] = 'production'

# Whenever this file is updated, make sure to update bluepill-initscript.sh!

Bluepill.application('rletters') do |app|

  app.uid = app.gid = 'rletters_deploy'

  app.process('puma') do |proc|
    proc.start_command = 'bundle exec puma -C /opt/rletters/root/config/puma.rb -e production -b unix:///opt/rletters/root/tmp/sockets/puma.sock'
    proc.stop_command = 'kill -QUIT {{PID}}'
    proc.restart_command = 'kill -USR2 {{PID}}'

    proc.pid_file = '/opt/rletters/root/tmp/pids/puma.pid'
    proc.daemonize = true
    proc.working_dir = '/opt/rletters/root'

    proc.start_grace_time = 60
    proc.stop_grace_time = 60
    proc.restart_grace_time = 180
  end

  app.process('resque-scheduler') do |proc|
    proc.start_command = 'RAILS_ENV=production bundle exec rake resque:scheduler'
    proc.stop_command = 'kill -QUIT {{PID}}'

    proc.pid_file = '/opt/rletters/root/tmp/pids/resque-scheduler.pid'
    proc.daemonize = true
    proc.working_dir = '/opt/rletters/root'

    proc.start_grace_time = 60
    proc.stop_grace_time = 60
    proc.restart_grace_time = 60
  end

  app.process('resque-pool') do |proc|
    proc.start_command = 'bundle exec resque-pool --daemon --environment production'
    proc.stop_command = 'kill -QUIT {{PID}}'
    proc.restart_command = 'kill -HUP {{PID}}'

    proc.pid_file = '/opt/rletters/root/tmp/pids/resque-pool.pid'
    proc.working_dir = '/opt/rletters/root'

    proc.start_grace_time = 60
    proc.stop_grace_time = 60
    proc.restart_grace_time = 180
  end

end
