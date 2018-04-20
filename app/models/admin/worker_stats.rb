
module Admin
  # A database table to track currently running job workers
  #
  # @!attribute worker_type
  #   @return [String] A free-form description of the type of job worker
  # @!attribute host
  #   @return [String] The host on which this worker is running
  # @!attribute pid
  #   @return [Integer] The PID of this worker
  # @!attribute started_at
  #   @return [DateTime] The time at which this worker was started
  class WorkerStats < ApplicationRecord
    self.table_name = 'admin_worker_stats'
  end
end
