# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe Jobs::Analysis::CraigZeta do

  it_should_behave_like 'an analysis job' do
    let(:job_params) { { other_datasets: [@dataset_2.id] } }
  end

  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, user: @user)
    @dataset_2 = create(:full_dataset, working: true, user: @user)
    @task = create(:analysis_task, dataset: @dataset)
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
    before(:example) do
      Jobs::Analysis::CraigZeta.perform(
        '123',
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        task_id: @task.to_param,
        other_datasets: [@dataset_2.to_param],
        normalize_doc_counts: 'off')
    end

    it 'names the task correctly' do
      expect(@dataset.analysis_tasks[0].name).to eq('Determine words that differentiate two datasets (Craig Zeta)')
    end

    it 'creates good JSON' do
      data = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))
      expect(data).to be_a(Hash)
    end

    it 'fills in some values' do
      hash = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))
      expect(hash['name_1']).to eq('Dataset')
      expect(hash['name_2']).to eq('Dataset')
      expect(hash['marker_words']).to be_an(Array)
      expect(hash['marker_words'][0]).to be_a(String)
      expect(hash['anti_marker_words']).to be_an(Array)
      expect(hash['anti_marker_words'][0]).to be_a(String)
      expect(hash['graph_points']).to be_an(Array)
      expect(hash['graph_points'][0]).to be_an(Array)
      expect(hash['graph_points'][0][0]).to be_a(Float)
      expect(hash['graph_points'][0][1]).to be_a(Float)
      expect(hash['graph_points'][0][2]).to be_a(String)
      expect(hash['zeta_scores']).to be_a(Hash)
      expect(hash['zeta_scores'].values[0]).to be_a(Float)
    end
  end

end
