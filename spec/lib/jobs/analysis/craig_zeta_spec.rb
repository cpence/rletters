require 'spec_helper'

RSpec.describe Jobs::Analysis::CraigZeta do
  before(:all) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, user: @user,
                                     entries_count: 2)
    @dataset_2 = create(:full_dataset, working: true, user: @user,
                                       entries_count: 2)
    @task = create(:analysis_task, dataset: @dataset)
  end

  before(:example) do
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
      expect(Jobs::Analysis::CraigZeta.download?).to be false
    end
  end

  describe '.num_datasets' do
    it 'is 2' do
      expect(Jobs::Analysis::CraigZeta.num_datasets).to eq(2)
    end
  end

  context 'when all parameters are valid' do
    before(:context) do
      Jobs::Analysis::CraigZeta.perform(
        '123',
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        task_id: @task.to_param,
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
