# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::Analysis::PlotDates, vcr: { cassette_name: 'plot_dates' } do

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
    @task = FactoryGirl.create(:analysis_task, dataset: @dataset)
  end

  after(:each) do
    @task.destroy
  end

  it_should_behave_like 'an analysis job with a file'

  context 'when not normalizing' do
    before(:each) do
      Jobs::Analysis::PlotDates.perform(
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        task_id: @task.to_param,
        normalize_doc_counts: 'off')
    end

    it 'names the task correctly' do
      expect(@dataset.analysis_tasks[0].name).to eq('Plot dataset by date')
    end

    it 'creates good JSON' do
      data = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))
      expect(data).to be_a(Hash)
    end

    it 'fills in some values' do
      arr = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))['data']
      expect((1990..2012)).to cover(arr[0][0])
      expect((1..5)).to cover(arr[0][1])
    end
  end

  context 'when normalizing to the corpus', vcr: { cassette_name: 'plot_dates_normalize_full' } do
    before(:each) do
      Jobs::Analysis::PlotDates.perform(
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        task_id: @task.to_param,
        normalize_doc_counts: '1',
        normalize_doc_dataset: '')
    end

    after(:each) do
      @task
    end

    it 'names the task correctly' do
      expect(@dataset.analysis_tasks[0].name).to eq('Plot dataset by date')
    end

    it 'creates good JSON' do
      arr = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))
      expect(arr).to be_a(Hash)
    end

    it 'sets the normalization set properly' do
      data = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))
      expect(data['normalization_set']).to eq('Entire Corpus')
    end

    it 'marks that this was a normalized count' do
      data = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))
      expect(data['percent']).to be_true
    end

    it 'fills in some values' do
      arr = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))['data']
      expect(arr.assoc(2000)[1]).to be_within(0.01).of(0.0322)
      expect(arr.assoc(2008)[1]).to be_within(0.01).of(0.016)
    end
  end

  context 'when normalizing to a dataset', vcr: { cassette_name: 'plot_dates_normalize_set', record: :new_episodes } do
    before(:each) do
      @normalization_set = FactoryGirl.create(:dataset, user: @user)
      %w(00040b66948f49c3a6c6c0977530e2014899abf9
         001954306c066a8a4cff3da02f7e9dda8e0fb634
         00496e7961871ad05013e1388aaa6650507b2638
         008896a5c58241b65088d931e02f3bea02fc3bf0
         00972c5123877961056b21aea4177d0dc69c7318
         0097c3434054c25e1ace6243a1ac54b71f35bc28
         0097e0f4029fef57b8158970112ab32c1e692cff
         00a004096479b9332b153e91053f09df8003ef74
         00cdb0f945c1e1d7b7789cd8178f3232a57fee34
         00dbffbfff2d18a74ed5f8895fa9f515bf38bf5f
         010510fa53f90934d9885dd578a0a450d9f97a0f
         011d1177aa42e0717747b33c0a9129d9d5edb3a7
         011f6bb9cb1f0abf80ea17c50db9988e6e2ee531
         013275fd04e96643930cc144eb64cb8d20087491
         013607db1f9b3383cebe405a5fecf215e9383536
         015738778211481abd5ca1b0275580e4ab009264
         0180fd13e5afd56b8a8c0714732e9d81665ab679
         019cc0557e2e4e7e4e6f9320557b7ab67724a725
         01a481a5d7e10f7e4932e12b697951bbd9292c94
         01aba6bb5df0e4f3941b17faa740197a32d71edc
         01acd240ba293b2990d3adb67937b8be06f9b36c
         01af4def15acd450900d94edf01a5fcf9bfeb2d3
         01f45860685ab79f8a43f68361fc4638b179ebef
         022384cffe3cc2b30e9e1fc8d88a4725c957dbe9
         023760a15166589267c924f13e25aa68e700ab3b
         0241b50927e8e14922710d609bb7236444598e16
         024f7f714e2dd5096110952155acaeb2457ef0d3
         02a642cd9e2e0f649464b491634595c2eb5184ac
         02a7cea8f2ab219a2cc3c1dc0575e2d9859a90e0
         02ba274a4f2697a924edd78ce8ac2afddd36a6fa).each do |shasum|
        FactoryGirl.create(:dataset_entry, dataset: @normalization_set, shasum: shasum)
      end

      Jobs::Analysis::PlotDates.perform(
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        task_id: @task.to_param,
        normalize_doc_counts: '1',
        normalize_doc_dataset: @normalization_set.id.to_s)
    end

    it 'names the task correctly' do
      expect(@dataset.analysis_tasks[0].name).to eq('Plot dataset by date')
    end

    it 'creates good JSON' do
      data = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))
      expect(data).to be_a(Hash)
    end

    it 'sets the normalization set properly' do
      data = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))
      expect(data['normalization_set']).to eq(@normalization_set.name)
    end

    it 'marks that this was a normalized count' do
      data = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))
      expect(data['percent']).to be_true
    end

    it 'fills in some values' do
      arr = JSON.load(@dataset.analysis_tasks[0].result.file_contents(:original))['data']
      expect(arr.assoc(2006)[1]).to be_within(0.01).of(0.25)
      expect(arr.assoc(2009)[1]).to be_within(0.01).of(0.5)
    end
  end

end
