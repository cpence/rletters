
# Expire any tasks older than two weeks.
class ExpireTasksJob < ApplicationJob
  queue_as :maintenance

  # Expire old tasks
  #
  # @return [void]
  def perform
    Datasets::Task.where('created_at < ?', 2.weeks.ago).destroy_all

    # Do it again in 4 hours
    ExpireTasksJob.set(wait: 4.hours).perform_later
  end
end
