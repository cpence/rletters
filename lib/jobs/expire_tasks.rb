
module Jobs
  # Expire any tasks older than two weeks.
  class ExpireTasks
    # Set the queue for this task
    #
    # @return [Symbol] the queue on which this job should run
    def self.queue
      :maintenance
    end

    # Expire old tasks
    #
    # @return [void]
    def self.perform
      Datasets::Task.destroy_all ['created_at < ?', 2.weeks.ago]
    end
  end
end
