# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::CreateDataset do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = @user.datasets.create(name: 'test', disabled: true)
  end

  context 'when user is invalid' do
    it 'raises an exception' do
      expect {
        Jobs::CreateDataset.perform(
          user_id: '12345678',
          dataset_id: @dataset.to_param,
          q: '*:*',
          fq: nil,
          defType: 'lucene')
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when dataset is invalid' do
    it 'raises an exception' do
      expect {
        Jobs::CreateDataset.perform(
          user_id: @user.to_param,
          dataset_id: '12345678',
          q: '*:*',
          fq: nil,
          defType: 'lucene')
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'given a standard search' do
    before(:each) do
      Jobs::CreateDataset.perform(
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        q: 'test',
        fq: nil,
        defType: 'dismax')

      @user.datasets.reload
    end

    it 'clears the disabled attribute' do
      expect(@user.datasets[0].disabled).to be_false
    end

    it 'puts the right number of items in the dataset' do
      expect(@user.datasets[0].entries).to have_at_least(10).items
    end
  end

  context 'given large Solr dataset' do
    before(:each) do
      Jobs::CreateDataset.perform(
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        q: '*:*',
        fq: nil,
        defType: 'lucene')

      @user.datasets.reload
    end

    it 'clears the disabled attribute' do
      expect(@user.datasets[0].disabled).to be_false
    end

    it 'puts the right number of items in the dataset' do
      expect(@user.datasets[0].entries).to have(1043).items
    end
  end

  context 'when Solr fails' do
    before(:each) do
      stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
    end

    it 'does not create a dataset' do
      expect {
        begin
          Jobs::CreateDataset.perform(
            user_id: @user.to_param,
            dataset_id: @dataset.to_param,
            q: 'test',
            fq: nil,
            defType: 'dismax')
        rescue StandardError
        end
      }.to change { Dataset.count }.by(-1)
    end

    it 'raises an exception' do
      expect {
        Jobs::CreateDataset.perform(
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          q: 'test',
          fq: nil,
          defType: 'dismax')
      }.to raise_error(StandardError)
    end
  end

end
