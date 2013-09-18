# -*- encoding : utf-8 -*-

module Jobs

  # Expire any analysis tasks older than two weeks.
  class ExpireAnalysisTasks

    # Expire old analysis tasks
    #
    # @api public
    # @return [undefined]
    # @example Start a job for expiring all old analysis tasks
    #   Resque.enqueue(Jobs::ExpireAnalysisTasks)
    def self.perform
      AnalysisTask.destroy_all ['created_at < ?', 2.weeks.ago]
    end
  end
end
