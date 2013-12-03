# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::Analysis::Network do

  it_should_behave_like 'an analysis job' do
    let(:job_params) { { word: 'ethology' } }
  end

  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = FactoryGirl.create(:full_dataset, working: true, user: @user)
    @task = FactoryGirl.create(:analysis_task, dataset: @dataset)
  end

  describe '.download?' do
    it 'is false' do
      expect(Jobs::Analysis::Network.download?).to be false
    end
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(Jobs::Analysis::Network.num_datasets).to eq(1)
    end
  end

  context 'when all parameters are valid' do
    before(:each) do
      Jobs::Analysis::Network.perform(
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        task_id: @task.to_param,
        word: 'ethology')
    end

    it 'names the task correctly' do
      expect(@dataset.analysis_tasks[0].name).to eq('Compute network of associated terms')
    end

    it 'creates good JSON' do
      data = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))
      expect(data).to be_a(Hash)
    end

    it 'fills in some values' do
      hash = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))
      expect(hash['name']).to eq('Dataset')
      expect(hash['word']).to eq('ethology')
      two_words = [hash['d3_nodes'][0]['name'], hash['d3_nodes'][1]['name']]
      expect(two_words).to include('ethology'.stem)
    end
  end

end
