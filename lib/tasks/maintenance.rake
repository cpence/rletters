
namespace :maintenance do
  desc 'Remove old finished tasks from the database'
  task expire_tasks: :environment do
    Datasets::Task.where('created_at < ?', 2.weeks.ago).destroy_all
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
