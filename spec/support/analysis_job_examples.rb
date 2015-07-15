require 'spec_helper'

RSpec.shared_context 'perform job with params' do
  before(:example) do
    if job_params
      described_class.new.perform(@task, job_params)
    else
      described_class.new.perform(@task)
    end
  end
end

RSpec.shared_examples_for 'an analysis job' do
  # Defaults for the configuration parameters -- specify these in a
  # customization block if you need extra/different parameters to create
  # your job or dataset.
  def job_params
    nil
  end

  def dataset_params
    nil
  end

  context 'when the job is finished' do
    it 'calls the finish! method on the task and sends an email' do
      mailer_ret = double
      expect(mailer_ret).to receive(:deliver_later).with(queue: :maintenance)

      expect(UserMailer).to receive(:job_finished_email).with(@task.dataset.user.email, @task.to_param).and_return(mailer_ret)

      if job_params
        described_class.new.perform(@task, job_params)
      else
        described_class.new.perform(@task)
      end

      @task.reload
      expect(@task.finished_at).to be
    end
  end

  context 'when a file is made' do
    include_context 'perform job with params'

    it 'makes a file for the task' do
      @task.reload
      expect(@task.result_file_size).to be > 0
    end
  end
end
