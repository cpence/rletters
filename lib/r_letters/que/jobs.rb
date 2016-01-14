
module RLetters
  module Que
    # Code to get information about all the currently running jobs
    module Jobs
      # SQL to fetch all future-scheduled jobs (thanks que-web)
      SCHEDULED_SQL = <<-SQL.freeze
        SELECT que_jobs.*
        FROM que_jobs
        LEFT JOIN (
          SELECT (classid::bigint << 32) + objid::bigint AS job_id
          FROM pg_locks
          WHERE locktype = 'advisory'
        ) locks USING (job_id)
        WHERE locks.job_id IS NULL AND error_count = 0
        ORDER BY run_at
      SQL

      # SQL to fetch all failing jobs
      FAILING_SQL = <<-SQL.freeze
        SELECT que_jobs.*
        FROM que_jobs
        LEFT JOIN (
          SELECT (classid::bigint << 32) + objid::bigint AS job_id
          FROM pg_locks
          WHERE locktype = 'advisory'
        ) locks USING (job_id)
        WHERE locks.job_id IS NULL AND error_count > 0
        ORDER BY run_at
      SQL

      # SQL to fetch a job from the table
      FETCH_SQL = <<-SQL.freeze
        SELECT *
        FROM que_jobs
        WHERE job_id = $1::bigint
        LIMIT 1
      SQL

      # SQL to delete a job
      DELETE_SQL = <<-SQL.freeze
        DELETE
        FROM que_jobs
        WHERE job_id = $1::bigint
      SQL

      # SQL to reschedule a job for a particular time
      RESCHEDULE_SQL = <<-SQL.freeze
        UPDATE que_jobs
        SET run_at = $2::timestamptz
        WHERE job_id = $1::bigint
      SQL

      # Get all currently scheduled, but not yet running, Que jobs
      #
      # This function returns an array of hashes. Each hash has the following
      # keys:
      # - args: the arguments passed to the job, usually (for our jobs) an
      #   array consisting of a single hash. This is stored in JSON format.
      # - error_count: number of errors registered for this job
      # - priority: the job priority (numeric)
      # - queue: the named queue on which this job runs
      # - run_at: the scheduled time for this job to run
      # - job_class: meaningless for our jobs, always an ActiveJob wrapper
      # - job_id: meaningless for our jobs, internal to Que, but needed to
      #   delete or reschedule the job
      # - last_error: datetime for the last error registered
      # - pg_backend_pid, pg_last_query, pg_last_query_started_at, pg_state,
      #   pg_state_changed_at, pg_transaction_started_at,
      #   pg_waiting_on_lock: a variety of information about the job's
      #   connection to Postgres
      #
      # @return [Array<Hash>] list of jobs
      def self.scheduled
        ::Que.execute(SCHEDULED_SQL)
      end

      # Get all currently failing Que jobs
      #
      # See `#scheduled` for the format of this array of hashes.
      #
      # @return [Array<Hash>] list of jobs
      def self.failing
        ::Que.execute(FAILING_SQL)
      end

      # Get full information about a particular job, by job_id
      #
      # @param [Integer] id ID of the job to fetch
      # @return [Hash] the job
      def self.get(id)
        res = ::Que.execute(FETCH_SQL, [id.to_i])
        return nil if res.empty?

        res.first
      end

      # Get a job or jobs by arguments in the JSON hash
      #
      # @param [Hash] filter a hash of arguments to screen jobs for
      # @return [Array<Hash>] the jobs, can be empty
      def self.get_by(filter)
        fetch_sql = <<-SQL
          SELECT *
          FROM que_jobs
        SQL

        queries = filter.map do |k, v|
          quoted_k = ActiveRecord::Base.connection.quote(k.to_s)
          quoted_v = ActiveRecord::Base.connection.quote(v.to_s)

          "args -> 0 ->> #{quoted_k} = #{quoted_v}"
        end

        fetch_sql << " WHERE #{queries.join(' AND ')}"
        ::Que.execute(fetch_sql)
      end

      # Delete a particular job, by job id
      #
      # @param [Integer] id ID of the job to delete
      # @return [void]
      def self.delete(id)
        ::Que.execute(DELETE_SQL, [id.to_i])
      end

      # Reschedule a job to run at a different time
      #
      # @param [Integer] id ID of the job to reschedule
      # @param [Time] time time to reschedule (defaults to now)
      # @return [void]
      def self.reschedule(id, time = Time.now)
        ::Que.execute(RESCHEDULE_SQL, [id.to_i, time])
      end
    end
  end
end
