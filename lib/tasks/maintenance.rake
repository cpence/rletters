
namespace :maintenance do
  desc 'Make sure the maintenance jobs are running'
  task :start do
    # Make sure there's at least one of every maintenance task actively
    # running in the queue
    que_stats = Que.job_stats
    running_job_classes = que_stats.map { |h| h['job_class'] }

    unless running_job_classes.include?('ExpireTasksJob')
      ExpireTasksJob.perform_later
    end
  end
end
