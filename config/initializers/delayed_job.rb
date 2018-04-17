
# Default configuration for DelayedJob workers. We'll work jobs one at a time,
# so none of the other configuration settings actually matter for us.
Delayed::Worker.delay_jobs = !Rails.env.test? && !ENV['BLOCKING_JOBS']
Delayed::Worker.max_attempts = 1
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'tmp', 'delayed_job.log'))
Delayed::Worker.max_run_time = 1.day
Delayed::Worker.destroy_failed_jobs = true
