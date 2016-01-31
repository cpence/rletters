require 'rails_helper'

RSpec.describe NetworkJob, type: :job do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, user: @user, num_docs: 0)
    create(:query, dataset: @dataset, q: "uid:\"#{WORKING_UIDS[2]}\"")
    @task = create(:task, dataset: @dataset)

    # The network code loads the English stop list
    @stop_list = create(:stop_list)
  end

  it_should_behave_like 'an analysis job' do
    let(:job_params) { { word: 'disease' } }
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(described_class.num_datasets).to eq(1)
    end
  end

  context 'when all parameters are valid' do
    before(:example) do
      described_class.new.perform(
        @task,
        focal_word: 'diseases')
      @task.reload
    end

    it 'names the task correctly' do
      expect(@task.name).to eq('Compute network of associated terms')
    end

    it 'creates good JSON' do
      data = JSON.load(@task.file_for('application/json').result.file_contents(:original))
      expect(data).to be_a(Hash)
    end

    it 'fills in some values' do
      hash = JSON.load(@task.file_for('application/json').result.file_contents(:original))
      expect(hash['name']).to eq('Dataset')
      expect(hash['focal_word']).to eq('diseases')
      expect(hash['d3_links'][0]['strength']).to be_within(0.01).of(0.7142857142857143)
    end
  end
end
