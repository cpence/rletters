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
    @task = FactoryGirl.create(:analysis_task, dataset: @dataset)
    @perform_args = { user_id: @user.to_param,
                      dataset_id: @dataset.to_param,
                      task_id: @task.to_param }.merge(job_params)
  end
end

shared_context 'create job with params and perform' do
  include_context 'create job with params'

  before(:each) do
    described_class.perform(@perform_args)
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
        described_class.perform(job_params.merge(
          { user_id: FactoryGirl.create(:user).to_param,
            dataset_id: @dataset.to_param,
            task_id: @task.to_param }))
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when an invalid user is specified' do
    it 'raises an exception' do
      expect {
        described_class.perform(job_params.merge(
          { user_id: '12345678',
            dataset_id: @dataset.to_param,
            task_id: @task.to_param }))
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when an invalid dataset is specified' do
    it 'raises an exception' do
      expect {
        described_class.perform(job_params.merge(
          { user_id: @user.to_param,
            dataset_id: '12345678',
            task_id: @task.to_param }))
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when an invalid task is specified' do
    it 'raises an exception' do
      expect {
        described_class.perform(job_params.merge(
          { user_id: @user.to_param,
            dataset_id: @dataset.to_param,
            task_id: '12345678' }))
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when the job is finished' do
    include_context 'create job with params'

    it 'calls the finish! method on the task' do
      described_class.perform(@perform_args)
      @task.reload
      expect(@task.finished_at).to be
    end

    it 'sends an e-mail' do
      ResqueSpec.reset!

      described_class.perform(@perform_args)
      expect(UserMailer).to have_queue_size_of(1)
      expect(UserMailer).to have_queued(:job_finished_email, @task.dataset.user.email, @task.to_param)
    end
  end

  context 'when a file is made' do
    include_context 'create job with params and perform'

    it 'makes a file for the task' do
      @task.reload
      expect(@task.result_file_size).to be > 0
    end
  end

  describe '.available?' do
    it 'is true' do
      expect(described_class.available?).to be true
    end
  end
end
