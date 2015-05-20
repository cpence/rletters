require 'spec_helper'

RSpec.shared_context 'create job with params' do
  before(:example) do
    @perform_args = { user_id: @user.to_param,
                      dataset_id: @dataset.to_param,
                      task_id: @task.to_param }.merge(job_params)
  end
end

RSpec.shared_context 'create job with params and perform' do
  include_context 'create job with params'

  before(:example) do
    described_class.perform('123', @perform_args)
  end
end

RSpec.shared_examples_for 'an analysis job' do
  # Defaults for the configuration parameters -- specify these in a
  # customization block if you need extra/different parameters to create
  # your job or dataset.
  def job_params
    {}
  end

  def dataset_params
    {}
  end

  context 'when the job is finished' do
    include_context 'create job with params'

    it 'calls the finish! method on the task and sends an email' do
      mailer_ret = double
      expect(mailer_ret).to receive(:deliver)

      expect(UserMailer).to receive(:job_finished_email).with(@task.dataset.user.email, @task.to_param).and_return(mailer_ret)

      described_class.perform('123', @perform_args)

      @task.reload
      expect(@task.finished_at).to be
    end
  end

  context 'when a file is made' do
    include_context 'create job with params and perform'

    it 'makes a file for the task' do
      @task.reload
      expect(@task.result_file_size).to be > 0
    end
  end
end
