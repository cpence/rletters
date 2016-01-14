require 'rails_helper'

# Mock jobs for testing the base code
class MockJob < BaseJob
  def perform(task, options = {})
    standard_options(task, options)
  end
end

class FailJob < BaseJob
  def perform(_)
    mock_que_job
    expect(RLetters::Que::Stats.stats[:total]).to eq(1)

    fail ArgumentError
  end
end

RSpec.describe BaseJob, type: :job do
  describe 'failure case' do
    before(:example) do
      @task = create(:task)
    end

    it 'sets the failure bit' do
      expect(@task.failed).to be false

      expect {
        perform_enqueued_jobs do
          FailJob.perform_later(@task)
        end
      }.not_to raise_exception

      @task.reload
      expect(@task.failed).to be true
    end

    it 'pulls the task from the Que queue' do
      expect {
        perform_enqueued_jobs do
          FailJob.perform_later(@task)
        end
      }.not_to raise_exception

      expect(RLetters::Que::Stats.stats[:total]).to eq(0)
    end
  end

  describe '.t' do
    it 'queries the right keys' do
      expect(I18n).to receive(:t).with('mock_job.testing', {})
      MockJob.t('.testing')
    end
  end

  describe '.job_list' do
    before(:example) do
      @jobs = described_class.job_list
    end

    it 'returns a non-empty array' do
      expect(@jobs).not_to be_empty
    end

    it 'contains a class we know exists' do
      expect(@jobs).to include(ExportCitationsJob)
    end
  end

  describe '.available?' do
    it 'is true by default' do
      expect(MockJob.available?).to be true
    end
  end

  describe '#dataset' do
    before(:example) do
      @task = create(:task)
      @job = MockJob.new
    end

    it 'works when we make a basic job' do
      @job.perform(@task)
      expect(@job.dataset).to eq(@task.dataset)
    end

    it 'fails when we make a multiple-dataset job' do
      dataset_2 = create(:dataset, user: @task.dataset.user)
      @job.perform(@task, other_datasets: [dataset_2.to_param])

      expect {
        @job.dataset
      }.to raise_error(ArgumentError)
    end
  end

  describe '#datasets' do
    before(:example) do
      @task = create(:task)
      @job = MockJob.new
    end

    it 'fails when we make a basic job' do
      @job.perform(@task)

      expect {
        @job.datasets
      }.to raise_error(ArgumentError)
    end

    it 'works when we make a multiple-dataset job' do
      dataset_2 = create(:dataset, user: @task.dataset.user)
      @job.perform(@task, other_datasets: [dataset_2.to_param])

      expect(@job.datasets[0]).to eq(@task.dataset)
      expect(@job.datasets[1]).to eq(dataset_2)
    end
  end

  describe '#check_task' do
    it 'raises an error when we kill the job' do
      @task = create(:task)
      @job = MockJob.new
      @job.perform(@task)

      @task.destroy
      expect {
        @job.dataset
      }.to raise_error(JobKilledError)
    end
  end
end
