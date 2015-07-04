require 'spec_helper'

RSpec.describe Jobs::Analysis::ExportCitations do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, entries_count: 10, working: true,
                                     user: @user)
    @task = create(:task, dataset: @dataset)
  end

  it_should_behave_like 'an analysis job' do
    let(:job_params) { { format: 'bibtex' } }
  end

  describe '.download?' do
    it 'is true' do
      expect(Jobs::Analysis::ExportCitations.download?).to be true
    end
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(Jobs::Analysis::ExportCitations.num_datasets).to eq(1)
    end
  end

  context 'when an invalid format is specified' do
    it 'raises an exception' do
      expect {
        Jobs::Analysis::ExportCitations.perform(
          '123',
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          task_id: @task.to_param,
          format: 'notaformat')
      }.to raise_error(ArgumentError)
    end
  end

  context 'when all parameters are valid' do
    before(:example) do
      Jobs::Analysis::ExportCitations.perform(
        '123',
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        task_id: @task.to_param,
        format: 'bibtex')
      @task.reload
    end

    it 'names the task correctly' do
      expect(@task.name).to eq('Export dataset as citations')
    end

    it 'creates a proper ZIP file' do
      data = @task.result.file_contents('original')
      entries = 0
      ::Zip::InputStream.open(StringIO.new(data)) do |zis|
        entries += 1 while zis.get_next_entry
      end
      expect(entries).to eq(10)
    end
  end
end
