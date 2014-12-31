
module Jobs
  # Expire any analysis tasks older than two weeks.
  class ExpireAnalysisTasks
    include Resque::Plugins::Status

    # Set the queue for this task
    #
    # @return [Symbol] the queue on which this job should run
    def self.queue
      :maintenance
    end

    # Expire old analysis tasks
    #
    # @return [void]
    def perform
      tick(I18n.t('jobs.expire_analysis_tasks.progress_expiring'))
      Datasets::AnalysisTask.destroy_all ['created_at < ?', 2.weeks.ago]

      completed
    end
  end
end
