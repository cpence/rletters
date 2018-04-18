
# Don't delay jobs in testing. Also, let the BLOCKING_JOBS setting force all
# jobs to the foreground thread.
Delayed::Worker.delay_jobs = !Rails.env.test? && !ENV['BLOCKING_JOBS']
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'tmp', 'delayed_job.log'))
