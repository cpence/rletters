rails_root = ENV['RAILS_ROOT'] || "/var/webapps/rletters"

# FIXME: We should probably be tweaking this value, and probably have multiple
# queues as well.
2.times do |num|
  God.watch do |w|
    w.name     = "delayed_job.#{num}"
    w.group    = 'delayed_job'
    
    w.interval = 30.seconds
    w.start_grace = 30.seconds
    w.restart_grace = 30.seconds
    
    script     = "cd #{rails_root}; /usr/bin/env RAILS_ENV=production bundle exec script/delayed_job --pid-dir=#{rails_root}/tmp/pids -i #{num}"
    w.start    = "/bin/bash -c '#{script}' start"
    w.stop     = "/bin/bash -c '#{script}' stop"
    
    w.log      = "#{rails_root}/log/god_delayed_job.#{num}.log"
    
    w.behavior(:clean_pid_file)
 
    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 5.seconds
        c.running = false
      end
    end
    
    w.restart_if do |restart|
      restart.condition(:memory_usage) do |c|
        c.above = 300.megabytes
        c.times = 2
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
end
