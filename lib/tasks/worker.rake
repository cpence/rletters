# frozen_string_literal: true

require 'socket'
require 'action_view/helpers/date_helper'

# Instantiate the date helpers for printing out our durations below
class DurationHelper
  include ActionView::Helpers::DateHelper
end

# Work one job, and then quit with an exit code. Designed to be monitored by
# our monitoring process.
namespace :rletters do
  namespace :jobs do
    desc 'Print statistics about running job workers'
    task stats: :environment do
      if Admin::WorkerStats.count.zero?
        puts '<no workers running>'
      else
        Admin::WorkerStats.all.each do |stat|
          duration = DurationHelper.new.distance_of_time_in_words(stat.started_at, Time.current)
          puts "Worker [#{stat.worker_type}]: PID #{stat.pid} on #{stat.host}, running since #{stat.started_at} (for #{duration})"
        end
      end
    end

    desc 'Run exactly one job from the analysis job queue'
    task analysis_work: :environment do
      # Record our presence in the DB
      stat = Admin::WorkerStats.create(
        worker_type: 'analysis worker',
        host: Socket.gethostname,
        pid: Process.pid,
        started_at: Time.current
      )

      begin
        worker = Delayed::Worker.new(quiet: true, queues: [:analysis])
        success, failure = worker.work_off(1)

        if success.zero? && failure.zero?
          Rails.logger.info 'No tasks available to work, exiting'
        elsif success == 1 && failure.zero?
          Rails.logger.info 'Successfully performed a single job'
        elsif success.zero? && failure == 1
          # Don't abort, however; we should have cleaned up after ourselves
          Rails.logger.error 'The job we were asked to run has failed'
        else
          raise "An unexpected combination of return codes resulted from working jobs (#{success}, #{failure})"
        end
      ensure
        stat.destroy
      end
    end

    desc 'Work the analysis job queue'
    task analysis: :environment do
      # Record our presence in the DB
      stat = Admin::WorkerStats.create(
        worker_type: 'analysis worker manager',
        host: Socket.gethostname,
        pid: Process.pid,
        started_at: Time.current
      )

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

    desc 'Work the maintenance job queue'
    task maintenance: :environment do
      # Record our presence in the DB
      stat = Admin::WorkerStats.create(
        worker_type: 'maintenance worker',
        host: Socket.gethostname,
        pid: Process.pid,
        started_at: Time.current
      )

      begin
        worker = Delayed::Worker.new(quiet: true,
                                     queues: [:maintenance],
                                     exit_on_complete: true)
        worker.start
      ensure
        stat.destroy
      end
    end
  end
end
