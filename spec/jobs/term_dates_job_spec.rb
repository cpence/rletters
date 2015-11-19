require 'rails_helper'

RSpec.describe TermDatesJob, type: :job do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, num_docs: 0, user: @user)
    create(:query, dataset: @dataset, q: "uid:\"gutenberg:3172\"")
    @task = create(:task, dataset: @dataset)
  end

  it_should_behave_like 'an analysis job' do
    let(:job_params) { { term: 'disease' } }
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(described_class.num_datasets).to eq(1)
    end
  end

  describe('.perform') do
    before(:example) do
      described_class.new.perform(
        @task,
        term: 'disease')
      @task.reload
      @data = JSON.load(@task.file_for('application/json').result.file_contents(:original))
    end

    it 'names the task correctly' do
      expect(@dataset.tasks[0].name).to eq('Plot word occurrences by date')
    end

    it 'creates two files' do
      expect(@task.files.count).to eq(2)
      expect(@task.file_for('application/json')).not_to be_nil
      expect(@task.file_for('text/csv')).not_to be_nil
    end

    it 'creates good JSON' do
      expect(@data).to be_a(Hash)
    end

    it 'fills in some values' do
      expect(@data['data'][0][0]).to be_in([1895, 2009])
      expect(0..10).to cover(@data['data'][0][1])
    end

    it 'fills in some zeroes in intervening years' do
      elt = @data['data'].find { |y| y[1] == 0 }
      expect(elt).to be
    end
  end
end
