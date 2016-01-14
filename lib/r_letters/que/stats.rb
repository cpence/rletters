
module RLetters
  # Code for communicating directly with the Que job server
  module Que
    # Code to get basic statistics about the currently running Que jobs
    module Stats
      # The SQL needed to get the basic statistics below (thanks to que-web)
      STATS_SQL = <<-SQL.freeze
        SELECT count(*)                    AS total,
               count(locks.job_id)         AS running,
               coalesce(sum((error_count > 0 AND locks.job_id IS NULL)::int), 0) AS failing,
               coalesce(sum((error_count = 0 AND locks.job_id IS NULL)::int), 0) AS scheduled
        FROM que_jobs
        LEFT JOIN (
          SELECT (classid::bigint << 32) + objid::bigint AS job_id
          FROM pg_locks
          WHERE locktype = 'advisory'
        ) locks USING (job_id)
      SQL

      # @return [Hash] A hash with keys for the current total, running,
      #   failing, and scheduled numbers of jobs (integers)
      def self.stats
        ::Que.execute(STATS_SQL)[0]
      end

      # Get information about the queue workers
      #
      # See Que's documentation on the `worker_states` command, which this is
      # just some syntactic sugar on top of.
      #
      # @return [Array<Hash>] Information about each running worker
      # :nocov:
      def self.workers
        ::Que.worker_states.map { |h| h.symbolize_keys }
      end
      # :nocov:
    end
  end
end
