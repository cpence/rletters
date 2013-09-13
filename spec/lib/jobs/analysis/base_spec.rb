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
    # A job that fails whenever it is called
    class FailingJob < Jobs::Analysis::Base
      def perform
        user = User.find(user_id)
        dataset = user.datasets.find(dataset_id)
        @task = dataset.analysis_tasks.create(name: 'This job always fails',
                                              job_type: 'FailingJob')

        raise ArgumentError
      end
    end
  end
end

describe Jobs::Analysis::Base do

  describe '.view_paths' do
    it 'returns the base path' do
      expected = Rails.root.join('lib', 'jobs', 'analysis', 'views', 'mock_job')
      expect(Jobs::Analysis::MockJob.view_paths).to include(expected)
    end
  end

  describe '.job_list' do
    before(:each) do
      @jobs = Jobs::Analysis::Base.job_list
    end

    it 'returns a non-empty array' do
      expect(@jobs).not_to be_empty
    end

    it 'contains a class we know exists' do
      expect(@jobs).to include(Jobs::Analysis::ExportCitations)
    end
  end

  describe '.error' do

    before(:each) do
      Delayed::Worker.delay_jobs = false

      @user = FactoryGirl.create(:user)
      @dataset = FactoryGirl.create(:full_dataset, user: @user)
      @job = Jobs::Analysis::FailingJob.new(user_id: @user.to_param,
                                            dataset_id: @dataset.to_param)

      # Yes, I know this raises an error, that is indeed
      # the point
      begin
        Delayed::Job.enqueue @job
      rescue ArgumentError # rubocop:disable HandleExceptions
      end
    end

    after(:each) do
      Delayed::Worker.delay_jobs = true
    end

    it 'creates an analysis task' do
      expect(@dataset.analysis_tasks[0]).to be
    end

    it 'sets the failed bit on the task' do
      expect(@dataset.analysis_tasks[0].failed).to be_true
    end
  end

end
