require 'rails_helper'

# Mock jobs for testing the base code
class MockJob < BaseJob; end
class FailJob < BaseJob
  def perform(_)
    # Mock what this would look like in the Que jobs table
    ActiveRecord::Base.connection.execute('DELETE FROM que_jobs')

    json = [{ 'job_class' => 'FailingJob', 'job_id' => @job_id,
              'queue_name' => 'maintenance', 'arguments' => [],
              'locale' => 'en' }].to_json
    query = <<-SQL
      INSERT INTO que_jobs
      (priority, run_at, job_id, job_class, args, error_count, queue) VALUES
      (100, now(), 1, 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper',
      '#{json}', 0, 'maintenance')
    SQL
    ActiveRecord::Base.connection.execute(query)

    expect(ActiveRecord::Base.connection.execute('SELECT * FROM que_jobs').count).to eq(1)

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

      expect(ActiveRecord::Base.connection.execute('SELECT * FROM que_jobs').count).to eq(0)
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
end
