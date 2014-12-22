# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe Jobs::Analysis::ArticleDates do
  before(:context) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, user: @user)
    @task = create(:analysis_task, dataset: @dataset)
  end

  it_should_behave_like 'an analysis job'

  describe '.download?' do
    it 'is false' do
      expect(Jobs::Analysis::ArticleDates.download?).to be false
    end
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(Jobs::Analysis::ArticleDates.num_datasets).to eq(1)
    end
  end

  context 'when not normalizing' do
    before(:context) do
      @dataset_2 = create(:full_dataset, working: true, user: @user)
      @dataset_2.entries += [create(:entry, dataset: @dataset_2, uid: 'gutenberg:3172')]
      @task_2 = create(:analysis_task, dataset: @dataset_2)

      Jobs::Analysis::ArticleDates.perform(
        '123',
        user_id: @user.to_param,
        dataset_id: @dataset_2.to_param,
        task_id: @task_2.to_param,
        normalize_doc_counts: 'off')
      @task_2.reload
      @data = JSON.load(@task_2.result.file_contents(:original))
    end

    it 'names the task correctly' do
      expect(@task_2.name).to eq('Plot number of articles by date')
    end

    it 'creates good JSON' do
      expect(@data).to be_a(Hash)
    end

    it 'fills in some values' do
      expect(@data['data'][0][0]).to be_in([2009, 1895])
      expect((1..5)).to cover(@data['data'][0][1])
    end

    it 'fills in some zeroes in intervening years' do
      elt = @data['data'].find { |y| y[1] == 0 }
      expect(elt).to be
    end
  end

  context 'when normalizing to the corpus' do
    before(:context) do
      Jobs::Analysis::ArticleDates.perform(
        '123',
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        task_id: @task.to_param,
        normalize_doc_counts: '1',
        normalize_doc_dataset: '')
      @task.reload
      @data = JSON.load(@task.result.file_contents(:original))
    end

    it 'names the task correctly' do
      expect(@task.name).to eq('Plot number of articles by date')
    end

    it 'creates good JSON' do
      expect(@data).to be_a(Hash)
    end

    it 'sets the normalization set properly' do
      expect(@data['normalization_set']).to eq('Entire Corpus')
    end

    it 'marks that this was a normalized count' do
      expect(@data['percent']).to be true
    end

    it 'fills in some values' do
      pair = @data['data'][0]
      expect((1859..2012)).to cover(pair[0])
      expect((0..1)).to cover(pair[1])
    end

    it 'expands the range of zeroes to include the entire corpus range' do
      expect(@data['data'].assoc(1910)).to be
      expect(@data['data'].assoc(1910)[1]).to eq(0)
    end
  end

  context 'when normalizing to a dataset' do
    before(:context) do
      @normalization_set = create(:full_dataset, working: true,
                                                 entries_count: 10,
                                                 user: @user)

      Jobs::Analysis::ArticleDates.perform(
        '123',
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        task_id: @task.to_param,
        normalize_doc_counts: '1',
        normalize_doc_dataset: @normalization_set.to_param)
      @task.reload
      @data = JSON.load(@task.result.file_contents(:original))
    end

    it 'names the task correctly' do
      expect(@task.name).to eq('Plot number of articles by date')
    end

    it 'creates good JSON' do
      expect(@data).to be_a(Hash)
    end

    it 'sets the normalization set properly' do
      expect(@data['normalization_set']).to eq(@normalization_set.name)
    end

    it 'marks that this was a normalized count' do
      expect(@data['percent']).to be true
    end

    it 'fills in some values' do
      pair = @data['data'][0]
      expect((1859..2012)).to cover(pair[0])
      expect((0..1)).to cover(pair[1])
    end
  end

  # We want to make sure it still works when we normalize to a dataset where
  # the dataset of interest isn't a subset
  context 'when normalizing incorrectly' do
    before(:context) do
      @normalization_set = create(:full_dataset, entries_count: 0, user: @user)
      @normalization_set.entries = [
        create(:entry, dataset: @normalization_set, uid: 'gutenberg:3172')
      ]
      @normalization_set.save

      Jobs::Analysis::ArticleDates.perform(
        '123',
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        task_id: @task.to_param,
        normalize_doc_counts: '1',
        normalize_doc_dataset: @normalization_set.to_param)
      @task.reload
      @data = JSON.load(@task.result.file_contents(:original))
    end

    it 'fills in zeros for all the values' do
      @data['data'].each do |a|
        expect(a[1]).to eq(0)
      end
    end
  end
end
