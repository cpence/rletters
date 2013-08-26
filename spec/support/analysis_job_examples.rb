# -*- encoding : utf-8 -*-
require 'spec_helper'

shared_context 'create job with params' do
  before(:each) do
    @user ||= FactoryGirl.create(:user)
    @dataset ||= FactoryGirl.create(
      :full_dataset,
      { user: @user,
        working: true,
        entries_count: 10 }.merge(dataset_params)
    )
    @job = described_class.new(
      { user_id: @user.to_param,
        dataset_id: @dataset.to_param }.merge(job_params)
    )
  end
end

shared_context 'create job with params and perform' do
  include_context 'create job with params'

  before(:each) do
    @job.perform
  end
end

shared_examples_for 'an analysis job' do
  # Defaults for the configuration parameters -- specify these in a
  # customization block if you need extra/different parameters to create
  # your job or dataset.
  def job_params
    {}
  end

  def dataset_params
    {}
  end

  context 'when the wrong user is specified' do
    it 'raises an exception' do
      expect {
        described_class.new(job_params.merge({ user_id: FactoryGirl.create(:user).to_param,
                                               dataset_id: @dataset.to_param })).perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when an invalid user is specified' do
    it 'raises an exception' do
      expect {
        described_class.new(job_params.merge({ user_id: '12345678',
                                               dataset_id: @dataset.to_param })).perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when an invalid dataset is specified' do
    it 'raises an exception' do
      expect {
        described_class.new(job_params.merge({ user_id: @user.to_param,
                                               dataset_id: '12345678' })).perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when all parameters are valid' do
    include_context 'create job with params and perform'

    it 'creates an analysis task' do
      expect(@dataset.analysis_tasks).to have(1).items
      expect(@dataset.analysis_tasks[0]).to be
    end
  end

  context 'when the job is finished' do
    include_context 'create job with params'

    it 'calls the finish! method' do
      expect_any_instance_of(AnalysisTask).to receive(:finish!)
      @job.perform
    end

    it 'sends an e-mail' do
      @job.perform
      expect(ActionMailer::Base.deliveries.last.to).to eq([@user.email])
    end
  end
end

shared_examples_for 'an analysis job with a file' do
  include_examples 'an analysis job'

  context 'when a file is made' do
    include_context 'create job with params and perform'

    it 'makes a file for the task' do
      expect(@dataset.analysis_tasks[0].result_file).to be
    end

    it 'creates the file on disk' do
      expect(File.exists?(@dataset.analysis_tasks[0].result_file.filename)).to be_true
    end
  end
end
