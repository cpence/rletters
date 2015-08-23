require 'rails_helper'

RSpec.describe ExportCitationsJob, type: :job do
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
      expect(described_class.download?).to be true
    end
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(described_class.num_datasets).to eq(1)
    end
  end

  context 'when an invalid format is specified' do
    it 'raises an exception' do
      expect {
        described_class.new.perform(
          @task,
          format: 'notaformat')
      }.to raise_error(ArgumentError)
    end
  end

  context 'when all parameters are valid' do
    before(:example) do
      described_class.new.perform(
        @task,
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
