require 'spec_helper'

# A mock job for testing the base code
class MockJob < BaseJob
  def call_standard_options(user_id, dataset_id, task_id)
    standard_options(user_id, dataset_id, task_id)
  end
end

RSpec.describe BaseJob, type: :job do
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

  describe '#standard_options!' do
    before(:example) do
      @user = create(:user)
      @dataset = create(:full_dataset, user: @user)
      @task = create(:task, dataset: @dataset)
    end

    context 'with the wrong user' do
      it 'raises an exception' do
        expect {
          MockJob.new.call_standard_options(create(:user).to_param,
                                            @dataset.to_param, @task.to_param)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with an invalid user' do
      it 'raises an exception' do
        expect {
          MockJob.new.call_standard_options('123456', @dataset.to_param,
                                            @task.to_param)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with an invalid dataset' do
      it 'raises an exception' do
        expect {
          MockJob.new.call_standard_options(@user.to_param, '123456',
                                            @task.to_param)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with an invalid task' do
      it 'raises an exception' do
        expect {
          MockJob.new.call_standard_options(@user.to_param, @dataset.to_param,
                                            '123456')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.available?' do
    it 'is true by default' do
      expect(MockJob.available?).to be true
    end
  end
end
