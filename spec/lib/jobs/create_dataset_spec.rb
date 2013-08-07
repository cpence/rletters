# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::CreateDataset do

  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  context 'when user is invalid' do
    it 'raises an exception' do
      expect {
        Jobs::CreateDataset.new(user_id: '12345678',
          name: 'Test Dataset', q: '*:*', fq: nil,
          qt: 'precise').perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'given a standard search',
          vcr: { cassette_name: 'create_dataset_standard' } do
    before(:each) do
      Jobs::CreateDataset.new(user_id: @user.to_param,
        name: 'Short Test Dataset', q: 'test', fq: nil,
        qt: 'standard').perform

      @user.datasets.reload
    end

    it 'creates a dataset' do
      @user.datasets.should have(1).items
      @user.datasets[0].should be
    end

    it 'puts the right number of items in the dataset' do
      @user.datasets[0].entries.should have_at_least(10).items
    end
  end

  context 'given large Solr dataset',
          vcr: { cassette_name: 'create_dataset_large' } do
    before(:each) do
      Jobs::CreateDataset.new(user_id: @user.to_param,
        name: 'Long Dataset', q: '*:*', fq: nil,
        qt: 'precise').perform

      @user.datasets.reload
    end

    it 'creates a dataset' do
      @user.datasets.should have(1).items
      @user.datasets[0].should be
    end

    it 'puts the right number of items in the dataset' do
      @user.datasets[0].entries.should have(1042).items
    end
  end

  context 'when Solr fails',
          vcr: { cassette_name: 'solr_fail' } do
    it 'does not create a dataset' do
      expect {
        begin
          Jobs::CreateDataset.new(user_id: @user.to_param,
            name: 'Failure Test Dataset', q: 'test', fq: nil,
            qt: 'standard').perform
        rescue StandardError
        end
      }.to_not change { Dataset.count }
    end

    it 'raises an exception' do
      expect {
        Jobs::CreateDataset.new(user_id: @user.to_param,
          name: 'Failure Test Dataset', q: 'test', fq: nil,
          qt: 'standard').perform
      }.to raise_error(StandardError)
    end
  end

end
