require 'resque/failure/base'

# Resque's namespace for all its code
module Resque
  # Resque's namespace for all failure adapters
  module Failure
    # A Resque failure class to set the failure bit on analysis tasks
    class Task < Base
      # Return the number of failures this adapter has logged
      #
      # We can't query the database to determine this, so just return Resque's
      # global number of failures (borrowed from the Airbrake adapter)
      #
      # @param [Symbol] _queue unused
      # @param [String] _class unused
      # @return [Integer] number of failed tasks
      #
      # :nocov:
      def self.count(_queue = nil, _class = nil)
        # This is a yes-or-no failure adapter, we don't actually keep track of
        # counts, so just fake this (borrowed from the Airbrake adapter)
        Stat[:failed]
      end
      # :nocov:

      # Attempt to look up the analysis task associated with this job and
      # fail it
      #
      # If we want the user interface to know that a given Resque job has
      # failed, we have to look up the task object on Resque failure and set
      # the failure bit.  Do that here.
      #
      # @return [void]
      def save
        klass = payload['class'].safe_constantize
        return unless klass

        # Only do this if we're in an analysis job of some sort
        return unless klass <= Jobs::Analysis::Base
        return unless payload['args'].size > 0

        args = payload['args'][1].symbolize_keys

        # If we can find all our parameters, save the thing
        return unless args[:user_id] && args[:dataset_id] && args[:task_id]

        begin
          user = User.find(args[:user_id])
          dataset = user.datasets.find(args[:dataset_id])
          task = dataset.tasks.find(args[:task_id])

          task.failed = true
          task.save!
        rescue ActiveRecord::RecordNotFound
          Resque.logger.warn 'Could not set failure bit for analysis task!'
        end
      end
    end
  end
end

# Enable this failure backend
require 'resque/failure/multiple'
require 'resque/failure/redis'
Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Task]
Resque::Failure.backend = Resque::Failure::Multiple
