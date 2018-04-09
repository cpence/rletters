
# Default configuration for DelayedJob workers
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 3
Delayed::Worker.delay_jobs = !Rails.env.test? && !ENV['BLOCKING_JOBS']
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'tmp', 'delayed_job.log'))

# Set the max run time to 36 hours. The watcher process will terminate any
# workers that have run for longer than 24.
Delayed::Worker.max_run_time = 36.hours

# If this is uncommented, then SIGTERM will cause workers to blow up with
# exceptions, abort their jobs, and unlock for other workers.
# Delayed::Worker.raise_signal_exceptions = :term
