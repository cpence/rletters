# frozen_string_literal: true

# Enable the Delayed Job queue adapter.
Rails.application.config.active_job.queue_adapter = :delayed_job

# Don't delay jobs in testing. Also, let the BLOCKING_JOBS setting force all
# jobs to the foreground thread.
Delayed::Worker.delay_jobs = !Rails.env.test? && !(ENV['BLOCKING_JOBS'] || 'false').to_bool
Delayed::Worker.logger = Logger.new(Rails.root.join('tmp', 'delayed_job.log'))

# We'll let these jobs run for twelve hours (by default), one time, after which
# point they will be killed by Timeout, their open jobs/tasks will be destroyed
# by the error handler in the rake task, and the DJ entry will be purged from
# the DB.
Delayed::Worker.max_attempts = 1
job_timeout = (ENV['JOB_TIMEOUT'] || '12').to_i
Delayed::Worker.max_run_time = job_timeout.hours
Delayed::Worker.destroy_failed_jobs = true
