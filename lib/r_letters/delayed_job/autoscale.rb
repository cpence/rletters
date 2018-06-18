# frozen_string_literal: true

module RLetters
  module DelayedJob
    # Support for auto-scaling job workers, locally and on Heroku.
    #
    # Thanks to https://github.com/phaza/Heroku-Delayed-Job-Autoscale for the
    # initial inspiration here, and a pointer in the direction of how to get
    # this done. I've updated that code here for new versions of the Heroku API
    # and our particular worker setup.
    module Autoscale
      # Scale up the worker pool if it is empty
      #
      # @return [void]
      def enqueue(job)
        s = scaler
        if s.num_workers.zero?
          s.scale_up
        end
      end

      # Scale down the worker pool if the queue is about to empty
      #
      # @return [void]
      def after(job)
        if Delayed::Job.where('queue = ?', 'analysis').count <= 1
          scaler.scale_down
        end
      end

      protected

      def scaler
        case ENV['AUTOSCALE_JOBS']
        when 'test'
          RLetters::DelayedJob::Autoscale::Test.new
        when 'heroku'
          RLetters::DelayedJob::Autoscale::Heroku.new
        when 'local'
          RLetters::DelayedJob::Autoscale::Local.new
        else
          RLetters::DelayedJob::Autoscale::Null.new
        end
      end
    end
  end
end
