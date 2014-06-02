# -*- encoding : utf-8 -*-
require 'spec_helper'

shared_context 'create job with params' do
  before(:each) do
    @user ||= create(:user)
    @dataset ||= create(
      :full_dataset,
      { user: @user,
        working: true,
        entries_count: 10 }.merge(dataset_params)
    )
    @task = create(:analysis_task, dataset: @dataset)
    @perform_args = { user_id: @user.to_param,
                      dataset_id: @dataset.to_param,
                      task_id: @task.to_param }.merge(job_params)
  end
end

shared_context 'create job with params and perform' do
  include_context 'create job with params'

  before(:each) do
    described_class.perform('123', @perform_args)
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
        described_class.perform(
          '123',
          job_params.merge(
            user_id: create(:user).to_param,
            dataset_id: @dataset.to_param,
            task_id: @task.to_param))
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when an invalid user is specified' do
    it 'raises an exception' do
      expect {
        described_class.perform(
          '123',
          job_params.merge(
            user_id: '12345678',
            dataset_id: @dataset.to_param,
            task_id: @task.to_param))
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when an invalid dataset is specified' do
    it 'raises an exception' do
      expect {
        described_class.perform(
          '123',
          job_params.merge(
            user_id: @user.to_param,
            dataset_id: '12345678',
            task_id: @task.to_param))
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when an invalid task is specified' do
    it 'raises an exception' do
      expect {
        described_class.perform(
          '123',
          job_params.merge(
            user_id: @user.to_param,
            dataset_id: @dataset.to_param,
            task_id: '12345678'))
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when the job is finished' do
    include_context 'create job with params'

    it 'sets the queue' do
      expect(described_class.methods).to include(:queue)
      expect(described_class.queue).to be_a(Symbol)
      expect(described_class.queue).to_not eq(:statused)
    end

    it 'includes the resque-status methods' do
      expect(described_class.methods).to include(:create)
    end

    it 'calls the finish! method on the task' do
      described_class.perform('123', @perform_args)
      @task.reload
      expect(@task.finished_at).to be
    end

    it 'sends an e-mail' do
      mailer_ret = double()
      expect(mailer_ret).to receive(:deliver)

      expect(UserMailer).to receive(:job_finished_email).with(@task.dataset.user.email, @task.to_param).and_return(mailer_ret)
      described_class.perform('123', @perform_args)
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
