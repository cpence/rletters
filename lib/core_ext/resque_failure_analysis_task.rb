# -*- encoding : utf-8 -*-
# Set the failed bit on analysis tasks when they fail.
require 'resque/failure/base'

class Resque::Failure::AnalysisTask < Resque::Failure::Base
  def self.count(queue = nil, class_name = nil)
    # This is a yes-or-no failure adapter, we don't actually keep track of
    # counts, so just fake this (borrowed from the Airbrake adapter)
    Stat[:failed]
  end

  def save
    klass = payload['class'].safe_constantize
    return unless klass

    # Only do this if we're in an analysis job of some sort
    if klass <= Jobs::Analysis::Base
      args = payload['args']

      # If we can find all our parameters, save the thing
      if args.count > 0 && args[0][:user_id] && args[0][:dataset_id] && args[0][:task_id]
        begin
          user = User.find(args[:user_id])
          dataset = user.datasets.find(args[:dataset_id])
          task = dataset.analysis_tasks.find(args[:task_id])

          task.failed = true
          task.save!
        rescue StandardException
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
