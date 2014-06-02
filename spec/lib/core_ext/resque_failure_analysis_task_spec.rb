# -*- encoding : utf-8 -*-
require 'spec_helper'

module Jobs
  module Analysis
    # A job that always throws an exception
    class FailingJob < Jobs::Analysis::Base
      include Resque::Plugins::Status

      def self.queue
        :ui
      end

      def perform
        fail 'This job always fails'
      end

      def self.run_with_worker(task, job_params)
        # We have to do this in a funny way to actually call the failure
        # handlers.  Thanks to Matt Conway (github/wr0ngway/graylog2-resque)
        # for this code.
        uuid = Jobs::Analysis::FailingJob.create(job_params)
        task.resque_key = uuid
        task.save

        worker = Resque::Worker.new(queue)
        def worker.done_working
          # Only work one job, then shut down
          super
          shutdown
        end

        job = worker.reserve
        worker.perform(job)
      end
    end
  end
end

describe Resque::Failure::AnalysisTask do
  before(:all) do
    Resque.inline = false
  end

  after(:all) do
    Resque.inline = true
  end

  describe '#save' do
    context 'with good parameters' do
      before(:each) do
        @user = create(:user)
        @dataset = create(:full_dataset, user: @user)
        @task = create(:analysis_task, dataset: @dataset, name: 'Failing task',
                                       job_type: 'FailingJob')

        job_params = {
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          task_id: @task.to_param
        }

        Jobs::Analysis::FailingJob.run_with_worker(@task, job_params)
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
            create(:analysis_task),
            user_id: 'asdf',
            dataset_id: 'asdf',
            task_id: 'asdf'
          )
        }.to_not raise_error
      end
    end
  end
end
