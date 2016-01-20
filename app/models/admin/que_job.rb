
module Admin
  # A wrapper class around jobs from Que
  #
  # Note that the structure of this model might change in the future, as we're
  # just mirroring the Que internals.
  #
  # Thanks to the que-web source for the `LEFT JOIN` magic down below.
  #
  # @!attribute priority
  #   @return [Integer] priority of this job
  # @!attribute run_at
  #   @return [Time] time at which this job will run
  # @!attribute job_id
  #   @return [Integer] internal Que ID of this job; used in several helper
  #     functions in the model
  # @!attribute job_class
  #   @return [String] meaningless for our jobs; an ActiveJob wrapper class
  # @!attribute args
  #   @return [String] a JSON representation of the arguments to this job, for
  #     our jobs almost always a single-element array containing a Hash
  # @!attribute error_count
  #   @return [Integer] number of errors this job has experienced
  # @!attribute last_error
  #   @return [String] information about the last recorded error
  # @!attribute queue
  #   @return [String] the queue on which this job is running
  class QueJob < ApplicationRecord
    self.table_name = :que_jobs

    # @return [Array<QueJob>] all jobs that are scheduled but not running
    scope(:scheduled, lambda do
      joins(<<-SQL)
        LEFT JOIN (
          SELECT (classid::bigint << 32) + objid::bigint AS job_id
          FROM pg_locks
          WHERE locktype = 'advisory'
        ) locks USING (job_id)
      SQL
        .where(locks: { job_id: nil }, error_count: 0)
        .order(:run_at)
    end)

    # @return [Array<QueJob>] all jobs that have failed to run
    scope(:failing, lambda do
      joins(<<-SQL)
        LEFT JOIN (
          SELECT (classid::bigint << 32) + objid::bigint AS job_id
          FROM pg_locks
          WHERE locktype = 'advisory'
        ) locks USING (job_id)
      SQL
        .where(locks: { job_id: nil }).where.not(error_count: 0)
        .order(:run_at)
    end)

    # Select a job or jobs by parameters in their arguments
    #
    # @return [Array<QueJob>] the jobs matching this filter
    def self.where_args(filter)
      return nil if filter.empty?
      rel = nil

      filter.each do |k, v|
        quoted_k = ActiveRecord::Base.connection.quote(k.to_s)
        quoted_v = ActiveRecord::Base.connection.quote(v.to_s)

        query = "args -> 0 ->> #{quoted_k} = #{quoted_v}"

        rel = (rel ? rel.where(query) : where(query))
      end

      rel
    end

    # @return (see ApplicationRecord.admin_attributes)
    def self.admin_attributes
      {
        queue: {},
        priority: {},
        run_at: {},
        args: {},
        error_count: {},
        last_error: {}
      }
    end

    # @return (see ApplicationRecord.admin_configuration)
    def self.admin_configuration
      { no_create: true, no_edit: true }
    end

    # Override the to_param method so that job_id-based fetching works
    #
    # @return [String] the job_id as a string
    def to_param
      job_id.to_s
    end

    # Override the find method so that job_id-based fetching works
    #
    # @param [String] id the id of the job to find
    # @return [QueJob] the requested job
    def self.find(id)
      Admin::QueJob.where(job_id: id.to_i).first
    end

    # Override the exists? method so that job_id-based fetching works
    #
    # @param [String] id the id of the job to find
    # @return [Boolean] true if the object exists, false otherwise
    def self.exists?(id)
      Admin::QueJob.where(job_id: id.to_i).count > 0
    end

    # Override the destroy method so that deleting works
    #
    # @return [void]
    def destroy
      # Delete all with the same job id as the current class
      Admin::QueJob.delete_all(job_id: job_id)

      freeze
    end

    # Override the bulk-destroy method so that bulk deleting works
    #
    # @param [String, Array] ids the ids to be destroyed
    # @return [void]
    def self.destroy(ids)
      ids = [ids] unless ids.is_a?(Array)
      ids.map!(&:to_i)

      Admin::QueJob.delete_all(job_id: ids)
    end
  end
end
