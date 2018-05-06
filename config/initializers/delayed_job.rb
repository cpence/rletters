# frozen_string_literal: true

# Don't delay jobs in testing. Also, let the BLOCKING_JOBS setting force all
# jobs to the foreground thread.
Delayed::Worker.delay_jobs = !Rails.env.test? && !ENV['BLOCKING_JOBS']
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'tmp', 'delayed_job.log'))

# We'll let these jobs run for one day, once, after which point they will be
# killed by Timeout, their open jobs/tasks, will be destroyed by the error
# handler above, and then the DJ entry will be purged from the DB.
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 1.day
Delayed::Worker.destroy_failed_jobs = true
