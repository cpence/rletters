require 'socket'
require 'action_view/helpers/date_helper'

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

# Instantiate the date helpers for printing out our durations below
class DurationHelper
  include ActionView::Helpers::DateHelper
end

# Work one job, and then quit with an exit code. Designed to be monitored by
# our monitoring process.
namespace :rletters do
  namespace :jobs do
    desc 'Print statistics about running job workers'
    task :stats => :environment do
      if Admin::WorkerStats.count == 0
        puts "<no workers running>"
      else
        Admin::WorkerStats.all.each do |stat|
          duration = DurationHelper.new.distance_of_time_in_words(stat.started_at, DateTime.now)
          puts "Worker [#{stat.worker_type}]: PID #{stat.pid} on #{stat.host}, running since #{stat.started_at} (for #{duration})"
        end
      end
    end

    desc 'Run exactly one job from the analysis job queue'
    task :analysis_work => :environment do
      # Record our presence in the DB
      stat = Admin::WorkerStats.create(
        worker_type: 'analysis worker',
        host: Socket.gethostname,
        pid: Process.pid,
        started_at: DateTime.now)

      begin
        worker = Delayed::Worker.new(quiet: true, queues: [:analysis])
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
      ensure
        stat.destroy
      end
    end

    desc 'Work the analysis job queue'
    task :analysis => :environment do
      # Record our presence in the DB
      stat = Admin::WorkerStats.create(
        worker_type: 'analysis worker manager',
        host: Socket.gethostname,
        pid: Process.pid,
        started_at: DateTime.now)

      begin
        # Simply work the analysis queue, one-at-a-time, until the end of time,
        # sleeping for 15 seconds between each go to let GC/VM catch up. Each
        # worker iteration should never take longer than 24h, according to our
        # configuration above.
        loop do
          system('bundle exec rake rletters:jobs:analysis_work')
          sleep 15
        end
      ensure
        stat.destroy
      end
    end

    desc 'Work tasks off the maintenance job queue'
    task :maintenance_work => :environment do
      # Record our presence in the DB
      stat = Admin::WorkerStats.create(
        worker_type: 'maintenance worker',
        host: Socket.gethostname,
        pid: Process.pid,
        started_at: DateTime.now)

      begin
        worker = Delayed::Worker.new(quiet: true,
                                     queues: [:maintenance],
                                     sleep_delay: 5)
        worker.start
      ensure
        stat.destroy
      end
    end

    desc 'Work the maintenance job queue'
    task :maintenance => :environment do
      # Record our presence in the DB
      stat = Admin::WorkerStats.create(
        worker_type: 'maintenance worker manager',
        host: Socket.gethostname,
        pid: Process.pid,
        started_at: DateTime.now)

      begin
        # Exceptions can cause this worker process to fail, restart it when
        # that happens
        loop do
          system('bundle exec rake rletters:jobs:maintenance_work')
          sleep 15
        end
      ensure
        stat.destroy
      end
    end
  end
end
