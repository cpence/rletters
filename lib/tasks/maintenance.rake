
namespace :maintenance do
  desc 'Make sure the maintenance jobs are running'
  task start: :environment do
    # Make sure there's at least one of every maintenance task actively
    # running in the queue
    que_stats = Que.job_stats
    running_job_classes = que_stats.map { |h| h['job_class'] }

    unless running_job_classes.include?('ExpireTasksJob')
      ExpireTasksJob.perform_later
    end
  end

  desc 'Print currently running queue sizes'
  task queue_list: :environment do
    puts Que.job_stats.to_json
  end

  desc 'Print current queue worker statistics'
  task queue_workers: :environment do
    puts Que.worker_states.to_json
  end
end
