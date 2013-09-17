# -*- encoding : utf-8 -*-
APP_PATH = "/opt/rletters/root"

# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
worker_processes 2

working_directory APP_PATH

# Listen on a Unix domain socket or a TCP port.
# We use a shorter backlog for quicker failover when busy.
listen "#{APP_PATH}/tmp/sockets/unicorn.sock", :backlog => 64

# Nuke workers after 30 seconds instead of 60 seconds (the default).
timeout 30

# Feel free to point this anywhere accessible on the filesystem.
pid "#{APP_PATH}/tmp/pids/unicorn.pid"

# By default, the Unicorn logger will write to stderr.
# Additionally, ome applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "#{APP_PATH}/log/unicorn.stderr.log"
stdout_path "#{APP_PATH}/log/unicorn.stdout.log"

preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  # The following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection.
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  # This allows a new master process to incrementally
  # phase out the old master process with SIGTTOU to avoid a
  # thundering herd (especially in the "preload_app false" case)
  # when doing a transparent upgrade.  The last worker spawned
  # will then kill off the old master process with a SIGQUIT.
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  # The following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
