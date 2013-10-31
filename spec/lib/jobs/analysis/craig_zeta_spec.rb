# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::Analysis::CraigZeta do

  it_should_behave_like 'an analysis job with a file' do
    let(:job_params) { { other_datasets: [@dataset_2.id] } }
  end

  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = FactoryGirl.create(:full_dataset, working: true, user: @user)
    @dataset_2 = FactoryGirl.create(:full_dataset, working: true, user: @user)
    @task = FactoryGirl.create(:analysis_task, dataset: @dataset)
  end

  after(:each) do
    @task.destroy
  end

  context 'when all parameters are valid' do
    before(:each) do
      Jobs::Analysis::CraigZeta.perform(
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
      hash['name_1'].should eq('Dataset')
      hash['name_2'].should eq('Dataset')
      hash['marker_words'].should be_an(Array)
      hash['marker_words'][0].should be_a(String)
      hash['anti_marker_words'].should be_an(Array)
      hash['anti_marker_words'][0].should be_a(String)
      hash['graph_points'].should be_an(Array)
      hash['graph_points'][0].should be_an(Array)
      hash['graph_points'][0][0].should be_a(Float)
      hash['graph_points'][0][1].should be_a(Float)
      hash['graph_points'][0][2].should be_a(String)
      hash['zeta_scores'].should be_a(Hash)
      hash['zeta_scores'].values[0].should be_a(Float)
    end
  end

end
