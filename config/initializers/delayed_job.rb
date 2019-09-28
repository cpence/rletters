# frozen_string_literal: true

# Enable the Delayed Job queue adapter.
ActiveJob::Base.queue_adapter = :delayed_job

# Don't delay jobs in testing. Also, let the BLOCKING_JOBS setting force all
# jobs to the foreground thread.
Delayed::Worker.delay_jobs = !Rails.env.test? && !(ENV['BLOCKING_JOBS'] || 'false').to_boolean
Delayed::Worker.logger = Logger.new(Rails.root.join('tmp', 'delayed_job.log'))

# We'll let these jobs run for twelve hours (by default), one time, after which
# point they will be killed by Timeout, their open jobs/tasks will be destroyed
# by the error handler in the rake task, and the DJ entry will be purged from
# the DB.
Delayed::Worker.max_attempts = 1
job_timeout = (ENV['JOB_TIMEOUT'] || '12').to_i
Delayed::Worker.max_run_time = job_timeout.hours
Delayed::Worker.destroy_failed_jobs = true

# Open up the job wrapper class used by ActiveJob, and add a failure
# handler an additional logging handlers to it.
#
# When Rails updates, we should check this against:
# https://github.com/rails/rails/blob/master/activejob/lib/active_job/queue_adapters/delayed_job_adapter.rb
module ActiveJob
  module QueueAdapters
    class DelayedJobAdapter
      class JobWrapper
        # Make sure that the job does not get rescheduled, regardless of what
        # might be happening with max_attempts elsewhere.
        #
        # @return [Integer] 1
        def max_attempts
          1
        end

        # Save the details of this error into our database so they aren't lost.
        #
        # TR14his is a callback, executed internally by DelajedJob.
        #
        # @param [Delayed::Job] job the job which failed
        # @param [Exception] exception the error which caused it to fail
        # @return [void]
        def error(job, exception)
          args = @job_data['arguments']

          # When this is called, the worker will have aborted the job, and
          # possibly attempted to reschedule it.
          if args
            begin
              args_real = ActiveJob::Arguments.deserialize(args)
              if args_real[0].is_a?(Datasets::Task)
                # Set the failed bit, and also try to save the failure message
                # from the exception as the final progress message
                args_real[0].failed = true
                args_real[0].progress_message = exception.message
                args_real[0].last_progress = Time.current
                args_real[0].save(validate: false)
              end
            rescue Exception # rubocop:disable HandleExceptions,RescueException
              # Quietly swallow errors if any of this fails, including the
              # standard system errors that you normally don't want to rescue.
            end
          end
        end
      end
    end
  end
end
