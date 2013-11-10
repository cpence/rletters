# -*- encoding : utf-8 -*-
require 'spec_helper'

module Jobs
  module Analysis
    # A job that always throws an exception
    class FailingJob < Jobs::Analysis::Base
      @queue = 'ui'
      def self.perform(args = {})
        raise 'This job always fails'
      end

      def self.run_with_worker(job_params)
        ResqueSpec.disable_ext = true

        # We have to do this in a funny way to actually call the failure
        # handlers.  Thanks to Matt Conway (github/wr0ngway/graylog2-resque)
        # for this code.
        queue = Resque.queue_from_class(Jobs::Analysis::FailingJob)
        Resque::Job.create(queue, Jobs::Analysis::FailingJob, job_params)
        worker = Resque::Worker.new(queue)

        def worker.done_working
          # Only work one job, then shut down
          super
          shutdown
        end

        job = worker.reserve
        worker.perform(job)

        ResqueSpec.disable_ext = false
      end
    end
  end
end

describe Resque::Failure::AnalysisTask do

  describe '#save' do
    context 'with good parameters' do
      before(:each) do
        @user = FactoryGirl.create(:user)
        @dataset = FactoryGirl.create(:full_dataset, user: @user)
        @task = FactoryGirl.create(:analysis_task,
                                   dataset: @dataset,
                                   name: 'Failing task',
                                   job_type: 'FailingJob')

        job_params = {
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          task_id: @task.to_param
        }

        Jobs::Analysis::FailingJob.run_with_worker(job_params)
      end

      it 'sets the failure bit on the analysis task' do
        @task.reload
        expect(@task.failed).to be true
      end
    end

    context 'with bad parameters' do
      it 'handles the exception gracefully' do
        expect {
          Jobs::Analysis::FailingJob.run_with_worker(
            user_id: 'asdf',
            dataset_id: 'asdf',
            task_id: 'asdf'
          )
        }.to_not raise_error
      end
    end
  end
end
