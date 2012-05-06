# -*- encoding : utf-8 -*-
require 'spec_helper'

module Jobs
  module Analysis
    class MockJob < Jobs::Analysis::Base
    end
  end
end

module Jobs
  module Analysis
    class FailingJob < Jobs::Analysis::Base
      def perform
        user = User.find(user_id)
        dataset = user.datasets.find(dataset_id)
        @task = dataset.analysis_tasks.create(:name => "This job always fails", :job_type => 'FailingJob')
        
        raise ArgumentError
      end
    end
  end
end

describe Jobs::Analysis::Base do

  describe '.view_path' do
    it 'returns the right value' do
      expected = File.join('jobs', 'mock_job', 'test')
      Jobs::Analysis::MockJob.view_path('test').should eq(expected)
    end
  end

  describe '.error' do
    
    before(:each) do
      Delayed::Worker.delay_jobs = false

      @user = FactoryGirl.create(:user)
      @dataset = FactoryGirl.create(:full_dataset, :user => @user)
      @job = Jobs::Analysis::FailingJob.new(:user_id => @user.to_param,
                                            :dataset_id => @dataset.to_param)

      # Yes, I know this raises an error, that is indeed
      # the point
      begin
        Delayed::Job.enqueue @job
      rescue ArgumentError; end
    end

    after(:each) do
      Delayed::Worker.delay_jobs = true
    end

    it 'creates an analysis task' do
      @dataset.analysis_tasks[0].should be
    end

    it 'sets the failed bit on the task' do
      @dataset.analysis_tasks[0].failed.should be_true
    end
  end
  
end
