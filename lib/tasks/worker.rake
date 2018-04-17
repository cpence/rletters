# Work one job, and then quit with an exit code. Designed to be monitored by
# our monitoring process.
namespace :rletters do
  namespace :jobs do
    desc 'Work the analysis job queue [RLetters]'
    task :analysis do
      # Open up the job wrapper class used by ActiveJob, and add a failure
      # handler to it. When Rails updates, we should check this against
      # https://github.com/rails/rails/blob/master/activejob/lib/active_job/queue_adapters/delayed_job_adapter.rb
      class ActiveJob::QueueAdapters::DelayedJobAdapter::JobWrapper
        def error(job, exception)
          # When this is called, the worker will have aborted the job, and
          # possibly attempted to reschedule it. What we want to do is try to
          # set the failure bit on the relevant task, if we can find it.
          args = @job_data['arguments']
          if args
            begin
              args_real = ActiveJob::Arguments.deserialize(args)
              if args_real[0].is_a?(Datasets::Task)
                args_real[0].failed = true
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

      worker = Delayed::Worker.new(quiet: true)
      success, failure = worker.work_off(1)

      if success == 0 && failure == 0
        puts 'No tasks available to work, exiting'
      elsif success == 1 && failure == 0
        puts 'Successfully performed a single job'
      elsif success == 0 && failure == 1
        fail 'The job we were asked to run has failed'
      else
        fail "An unexpected combination of return codes resulted from working jobs (#{success}, #{failure}), aborting"
      end
    end
  end
end
