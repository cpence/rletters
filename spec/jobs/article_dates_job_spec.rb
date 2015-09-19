require 'rails_helper'

RSpec.describe ArticleDatesJob, type: :job do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, user: @user)
    @task = create(:task, dataset: @dataset)
  end

  it_should_behave_like 'an analysis job'

  describe '.num_datasets' do
    it 'is 1' do
      expect(described_class.num_datasets).to eq(1)
    end
  end

  context 'when not normalizing' do
    before(:example) do
      @dataset_2 = create(:full_dataset, working: true, user: @user)
      @dataset_2.entries += [create(:entry, dataset: @dataset_2, uid: 'gutenberg:3172')]
      @task_2 = create(:task, dataset: @dataset_2)

      described_class.new.perform(
        @task_2,
        normalize_doc_counts: 'off')
      @task_2.reload
      @data = JSON.load(@task_2.file_for('application/json').result.file_contents(:original))
    end

    it 'names the task correctly' do
      expect(@task_2.name).to eq('Plot number of articles by date')
    end

    it 'creates two files' do
      expect(@task_2.files.count).to eq(2)
      expect(@task_2.file_for('application/json')).not_to be_nil
      expect(@task_2.file_for('text/csv')).not_to be_nil
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
    before(:example) do
      described_class.new.perform(
        @task,
        normalize_doc_counts: '1',
        normalize_doc_dataset: '')
      @task.reload
      @data = JSON.load(@task.file_for('application/json').result.file_contents(:original))
    end

    it 'names the task correctly' do
      expect(@task.name).to eq('Plot number of articles by date')
    end

    it 'creates two files' do
      expect(@task.files.count).to eq(2)
      expect(@task.file_for('application/json')).not_to be_nil
      expect(@task.file_for('text/csv')).not_to be_nil
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
    before(:example) do
      @normalization_set = create(:full_dataset, working: true,
                                                 entries_count: 10,
                                                 user: @user)

      described_class.new.perform(
        @task,
        normalize_doc_counts: '1',
        normalize_doc_dataset: @normalization_set.to_param)
      @task.reload
      @data = JSON.load(@task.file_for('application/json').result.file_contents(:original))
    end

    it 'names the task correctly' do
      expect(@task.name).to eq('Plot number of articles by date')
    end

    it 'creates two files' do
      expect(@task.files.count).to eq(2)
      expect(@task.file_for('application/json')).not_to be_nil
      expect(@task.file_for('text/csv')).not_to be_nil
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
    before(:example) do
      @normalization_set = create(:full_dataset, entries_count: 0, user: @user)
      @normalization_set.entries = [
        create(:entry, dataset: @normalization_set, uid: 'gutenberg:3172')
      ]
      @normalization_set.save

      described_class.new.perform(
        @task,
        normalize_doc_counts: '1',
        normalize_doc_dataset: @normalization_set.to_param)
      @task.reload
      @data = JSON.load(@task.file_for('application/json').result.file_contents(:original))
    end

    it 'fills in zeros for all the values' do
      @data['data'].each do |a|
        expect(a[1]).to eq(0)
      end
    end
  end
end
