require 'rails_helper'

RSpec.describe CraigZetaJob, type: :job do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, user: @user, num_docs: 2)
    @dataset_2 = create(:full_dataset, working: true, user: @user, num_docs: 2)
    @task = create(:task, dataset: @dataset)

    # Don't run the analyses
    mock = double(RLetters::Analysis::CraigZeta,
                  zeta_scores: {}, dataset_1_markers: [],
                  dataset_2_markers: [], graph_points: [])
    allow(RLetters::Analysis::CraigZeta).to receive(:call).and_return(mock)
  end

  it_should_behave_like 'an analysis job' do
    let(:job_params) { { other_datasets: [@dataset_2.id] } }
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
        other_datasets: [@dataset_2.to_param])
      @task.reload
      @data = JSON.load(@task.file_for('application/json').result.file_contents(:original))
    end

    it 'names the task correctly' do
      expect(@task.name).to eq('Determine words that differentiate two datasets (Craig Zeta)')
    end

    it 'creates two files' do
      expect(@task.files.count).to eq(2)
      expect(@task.file_for('application/json')).not_to be_nil
      expect(@task.file_for('text/csv')).not_to be_nil
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
      expect(@data['zeta_scores']).to be_a(Array)
    end
  end
end
