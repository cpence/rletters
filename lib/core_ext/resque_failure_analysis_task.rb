# -*- encoding : utf-8 -*-
# Set the failed bit on analysis tasks when they fail.
require 'resque/failure/base'

class Resque::Failure::AnalysisTask < Resque::Failure::Base
  # Return the number of failures this adapter has logged
  #
  # We can't query the database to determine this, so just return Resque's
  # global number of failures (borrowed from the Airbrake adapter)
  # :nocov:
  def self.count(queue = nil, class_name = nil)
    # This is a yes-or-no failure adapter, we don't actually keep track of
    # counts, so just fake this (borrowed from the Airbrake adapter)
    Stat[:failed]
  end
  # :nocov:

  def save
    klass = payload['class'].safe_constantize
    return unless klass

    # Only do this if we're in an analysis job of some sort
    if klass <= Jobs::Analysis::Base
      if payload['args'].count > 0
        args = payload['args'][0].symbolize_keys

        # If we can find all our parameters, save the thing
        if args[:user_id] && args[:dataset_id] && args[:task_id]
          begin
            user = User.find(args[:user_id])
            dataset = user.datasets.find(args[:dataset_id])
            task = dataset.analysis_tasks.find(args[:task_id])

            task.failed = true
            task.save!
          rescue StandardError
          end
        end
      end
    end
  end
end

# Enable this failure backend
require 'resque/failure/multiple'
require 'resque/failure/redis'
Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::AnalysisTask]
Resque::Failure.backend = Resque::Failure::Multiple
