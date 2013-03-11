rails_root = ENV['RAILS_ROOT'] || "/var/webapps/rletters"

God.watch do |w|
  w.name     = 'clockwork'
    
  w.interval = 30.seconds
  w.start_grace = 30.seconds
  w.restart_grace = 30.seconds
    
  script     = "cd #{rails_root}; /usr/bin/env RAILS_ENV=production bundle exec clockworkd --pid-dir=#{rails_root}/tmp/pids --log-dir=#{rails_root}/log --log -i 0 --clock=#{rails_root}/config/clock.rb"
  w.start    = "/bin/bash -c '#{script} start'"
  w.stop     = "/bin/bash -c '#{script} stop'"
    
  w.log      = "#{rails_root}/log/god_clockworkd.log"
  w.pid_file = "#{rails_root}/tmp/pids/clockworkd.0.pid"
  
  w.behavior(:clean_pid_file)
 
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
    
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minutes
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end
