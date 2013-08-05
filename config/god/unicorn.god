# http://unicorn.bogomips.org/SIGNALS.html
# Thanks to https://github.com/blog/519-unicorn-god

rails_root = ENV['RAILS_ROOT'] || '/var/webapps/rletters'

God.watch do |w|
  w.name = 'unicorn'

  w.interval = 30.seconds
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds

  w.start = "cd #{rails_root} && bundle exec unicorn -c #{rails_root}/config/unicorn.rb -E production -D"
  # QUIT gracefully shuts down workers
  w.stop = "kill -QUIT `cat #{rails_root}/tmp/pids/unicorn.pid`"
  # USR2 causes the master to re-create itself and spawn a new worker pool
  w.restart = "kill -USR2 `cat #{rails_root}/tmp/pids/unicorn.pid`"

  w.log = "#{rails_root}/log/god_unicorn.log"
  w.pid_file = "#{rails_root}/tmp/pids/unicorn.pid"

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
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
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
