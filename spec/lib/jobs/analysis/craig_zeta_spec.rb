# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::Analysis::CraigZeta, vcr: { cassette_name: 'craig_zeta' } do

  it_should_behave_like 'an analysis job with a file' do
    let(:job_params) { { other_dataset_id: @dataset_2.id } }
  end

  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = FactoryGirl.create(:dataset, user: @user)
    %w(00040b66948f49c3a6c6c0977530e2014899abf9
       001954306c066a8a4cff3da02f7e9dda8e0fb634
       00496e7961871ad05013e1388aaa6650507b2638
       008896a5c58241b65088d931e02f3bea02fc3bf0
       00972c5123877961056b21aea4177d0dc69c7318
       0097c3434054c25e1ace6243a1ac54b71f35bc28
       0097e0f4029fef57b8158970112ab32c1e692cff
       00a004096479b9332b153e91053f09df8003ef74
       00cdb0f945c1e1d7b7789cd8178f3232a57fee34
       00dbffbfff2d18a74ed5f8895fa9f515bf38bf5f).each do |shasum|
      FactoryGirl.create(:dataset_entry, dataset: @dataset, shasum: shasum)
    end
    @dataset_2 = FactoryGirl.create(:dataset, user: @user)
    %w(010510fa53f90934d9885dd578a0a450d9f97a0f
       011d1177aa42e0717747b33c0a9129d9d5edb3a7
       011f6bb9cb1f0abf80ea17c50db9988e6e2ee531
       013275fd04e96643930cc144eb64cb8d20087491
       013607db1f9b3383cebe405a5fecf215e9383536
       015738778211481abd5ca1b0275580e4ab009264
       0180fd13e5afd56b8a8c0714732e9d81665ab679
       019cc0557e2e4e7e4e6f9320557b7ab67724a725
       01a481a5d7e10f7e4932e12b697951bbd9292c94
       01aba6bb5df0e4f3941b17faa740197a32d71edc).each do |shasum|
      FactoryGirl.create(:dataset_entry, dataset: @dataset_2, shasum: shasum)
    end
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
        other_dataset_id: @dataset_2.to_param,
        normalize_doc_counts: 'off')
    end

    it 'names the task correctly' do
      expect(@dataset.analysis_tasks[0].name).to eq('Differentiate two datasets (Craig Zeta)')
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
      hash['graph_points'][0][0].should be_a(String)
      hash['graph_points'][0][1].should be_a(Float)
      hash['graph_points'][0][2].should be_a(Float)
      hash['zeta_scores'].should be_a(Hash)
      hash['zeta_scores'].values[0].should be_a(Float)
    end
  end

end
