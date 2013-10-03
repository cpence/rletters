# -*- encoding : utf-8 -*-
require 'spec_helper'

module Jobs
  module Analysis
    class FailingJob < Jobs::Analysis::Base
      @queue = 'ui'
      def self.perform(args = {})
        raise 'This job always fails'
      end
    end
  end
end

describe Resque::Failure::AnalysisTask do

  describe '#save' do
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

      without_resque_spec do
        # We jave to do this in a funny way to actually call the failure
        # handlers.  Thanks to Matt Conway (github/wr0ngway/graylog2-resque)
        # for this code.
        queue = Resque.queue_from_class(Jobs::Analysis::FailingJob)
        Resque::Job.create(queue, Jobs::Analysis::FailingJob, *job_params)
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

    it 'sets the failure bit on the analysis task' do
      @task.reload
      expect(@task.failed).to be_true
    end
  end
end
