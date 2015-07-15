require 'spec_helper'

RSpec.describe CraigZetaJob, type: :job do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, user: @user,
                                     entries_count: 2)
    @dataset_2 = create(:full_dataset, working: true, user: @user,
                                       entries_count: 2)
    @task = create(:task, dataset: @dataset)

    # Don't run the analyses
    mock = double(RLetters::Analysis::CraigZeta,
                  zeta_scores: [], dataset_1_markers: [],
                  dataset_2_markers: [], graph_points: [])
    allow(mock).to receive(:call)
    allow(RLetters::Analysis::CraigZeta).to receive(:new).and_return(mock)
  end

  it_should_behave_like 'an analysis job' do
    let(:job_params) { { other_datasets: [@dataset_2.id] } }
  end

  describe '.download?' do
    it 'is false' do
      expect(described_class.download?).to be false
    end
  end

  describe '.num_datasets' do
    it 'is 2' do
      expect(described_class.num_datasets).to eq(2)
    end
  end

  context 'when all parameters are valid' do
    before(:example) do
      described_class.new.perform(
        @task,
        other_datasets: [@dataset_2.to_param],
        normalize_doc_counts: 'off')
      @task.reload
      @data = JSON.load(@task.result.file_contents(:original))
    end

    it 'names the task correctly' do
      expect(@task.name).to eq('Determine words that differentiate two datasets (Craig Zeta)')
    end

    it 'creates good JSON' do
      expect(@data).to be_a(Hash)
    end

    it 'fills in some values' do
      expect(@data['name_1']).to eq('Dataset')
      expect(@data['name_2']).to eq('Dataset')
      expect(@data['markers_1']).to be_an(Array)
      expect(@data['markers_2']).to be_an(Array)
      expect(@data['graph_points']).to be_an(Array)
      expect(@data['zeta_scores']).to be_an(Array)
    end
  end
end
