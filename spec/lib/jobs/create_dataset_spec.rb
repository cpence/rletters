require 'spec_helper'
require 'r_letters/solr/connection'

RSpec.describe Jobs::CreateDataset do
  before(:example) do
    @user = create(:user)
    @dataset = @user.datasets.create(name: 'test', disabled: true)
  end

  context 'when user is invalid' do
    it 'raises an exception' do
      expect {
        Jobs::CreateDataset.perform(
          '123',
          user_id: '12345678',
          dataset_id: @dataset.to_param,
          q: '*:*',
          fq: nil,
          def_type: 'lucene')
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when dataset is invalid' do
    it 'raises an exception' do
      expect {
        Jobs::CreateDataset.perform(
          '123',
          user_id: @user.to_param,
          dataset_id: '12345678',
          q: '*:*',
          fq: nil,
          def_type: 'lucene')
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'given a standard search' do
    before(:example) do
      Jobs::CreateDataset.perform(
        '123',
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        q: 'test',
        fq: nil,
        def_type: 'dismax')

      @dataset.reload
    end

    it 'clears the disabled attribute' do
      expect(@dataset.disabled).to be false
    end

    it 'puts the right number of items in the dataset' do
      expect(@dataset.entries.size).to be >= 10
    end

    it 'does not set the fetch attribute' do
      # The word 'test' does not appear in our external document, so it
      # shouldn't be returned in this search.
      expect(@dataset.fetch).to be false
    end
  end

  context 'when the user has an active workflow' do
    before(:example) do
      @user.workflow_active = true
      @user.save

      Jobs::CreateDataset.perform(
        '123',
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        q: 'test',
        fq: nil,
        def_type: 'dismax')

      @user.reload
      @user.datasets.reload
    end

    it 'links the dataset to the workflow' do
      expect(@user.workflow_datasets).to eq(@user.datasets)
    end
  end

  context 'given large Solr dataset' do
    before(:example) do
      Jobs::CreateDataset.perform(
        '123',
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        q: '*:*',
        fq: nil,
        def_type: 'lucene')

      @dataset.reload
    end

    it 'clears the disabled attribute' do
      expect(@dataset.disabled).to be false
    end

    it 'puts the right number of items in the dataset' do
      expect(@dataset.entries.size).to eq(1502)
    end

    it 'sets the fetch attribute' do
      expect(@dataset.fetch).to be true
    end
  end

  context 'when Solr fails' do
    before(:example) do
      stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
    end

    it 'does not create a dataset' do
      expect {
        expect {
          Jobs::CreateDataset.perform(
            '123',
            user_id: @user.to_param,
            dataset_id: @dataset.to_param,
            q: 'test',
            fq: nil,
            def_type: 'dismax')
        }.to raise_error(RLetters::Solr::ConnectionError)
      }.to change { Dataset.all.count }.by(-1)
    end

    it 'raises an exception' do
      expect {
        Jobs::CreateDataset.perform(
          '123',
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          q: 'test',
          fq: nil,
          def_type: 'dismax')
      }.to raise_error(RLetters::Solr::ConnectionError)
    end
  end
end
