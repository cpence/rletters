# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::CreateDataset do

  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  context 'when user is invalid' do
    it 'raises an exception' do
      expect {
        Jobs::CreateDataset.perform(
          user_id: '12345678',
          name: 'Test Dataset',
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
        name: 'Short Test Dataset',
        q: 'test',
        fq: nil,
        defType: 'dismax')

      @user.datasets.reload
    end

    it 'creates a dataset' do
      expect(@user.datasets).to have(1).items
      expect(@user.datasets[0]).to be
    end

    it 'puts the right number of items in the dataset' do
      expect(@user.datasets[0].entries).to have_at_least(10).items
    end
  end

  context 'given large Solr dataset' do
    before(:each) do
      Jobs::CreateDataset.perform(
        user_id: @user.to_param,
        name: 'Long Dataset',
        q: '*:*',
        fq: nil,
        defType: 'lucene')

      @user.datasets.reload
    end

    it 'creates a dataset' do
      expect(@user.datasets).to have(1).items
      expect(@user.datasets[0]).to be
    end

    it 'puts the right number of items in the dataset' do
      expect(@user.datasets[0].entries).to have(1042).items
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
            name: 'Failure Test Dataset',
            q: 'test',
            fq: nil,
            defType: 'dismax')
        rescue StandardError
        end
      }.to_not change { Dataset.count }
    end

    it 'raises an exception' do
      expect {
        Jobs::CreateDataset.perform(
          user_id: @user.to_param,
          name: 'Failure Test Dataset',
          q: 'test',
          fq: nil,
          defType: 'dismax')
      }.to raise_error(StandardError)
    end
  end

end
