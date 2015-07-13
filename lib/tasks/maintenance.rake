
namespace :maintenance do
  desc 'Start running the maintenance jobs'
  task :start do
    # Maintenance tasks will then re-queue themselves after running
    ExpireTasksJob.perform_later
  end
end
