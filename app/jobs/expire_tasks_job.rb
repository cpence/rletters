
# Expire any tasks older than two weeks.
class ExpireTasksJob < ActiveJob::Base
  queue_as :maintenance

  # Expire old tasks
  #
  # @return [void]
  def perform
    Datasets::Task.destroy_all ['created_at < ?', 2.weeks.ago]

    # Do it again in 4 hours
    ExpireTasksJob.set(wait: 4.hours).perform_later
  end
end
