# Open up the job wrapper class used by ActiveJob, and add a failure
# handler to it. When Rails updates, we should check this against
# https://github.com/rails/rails/blob/master/activejob/lib/active_job/queue_adapters/delayed_job_adapter.rb
class ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper
  def error(job, exception)
    # When this is called, the worker will have aborted the job, and
    # possibly attempted to reschedule it.
    args = @job_data['arguments']
    if args
      begin
        args_real = ActiveJob::Arguments.deserialize(args)
        if args_real[0].is_a?(Datasets::Task)
          # Set the failed bit, and also try to save the failure message
          # from the exception as the final progress message
          args_real[0].failed = true
          args_real[0].progress_message = exception.message
          args_real[0].last_progress = DateTime.now
          args_real[0].save(validate: false)
        end
      rescue Exception
        # Quietly swallow errors if any of this fails
      end
    end

    # Don't let it be rescheduled, whatever we do.
    job.destroy
  end
end

# Work one job, and then quit with an exit code. Designed to be monitored by
# our monitoring process.
namespace :rletters do
  namespace :jobs do
    def work_one_analysis
      worker = Delayed::Worker.new(quiet: true)
      success, failure = worker.work_off(1)

      if success == 0 && failure == 0
        Rails.logger.info 'No tasks available to work, exiting'
      elsif success == 1 && failure == 0
        Rails.logger.info 'Successfully performed a single job'
      elsif success == 0 && failure == 1
        # Don't abort, however; we should have cleaned up after ourselves
        Rails.logger.error 'The job we were asked to run has failed'
      else
        fail "An unexpected combination of return codes resulted from working jobs (#{success}, #{failure})"
      end
    end

    desc 'Run exactly one job from the analysis job queue'
    task :analysis_one => :environment do
      work_one_analysis
    end

    desc 'Work the analysis job queue'
    task :analysis => :environment do
      # Simply work the analysis queue, one-at-a-time, until the end of time,
      # sleeping for 15 seconds between each go to let GC/VM catch up. Each
      # worker iteration should never take longer than 24h, according to our
      # configuration above.
      loop do
        work_one_analysis
        sleep 15
      end
    end
  end
end
