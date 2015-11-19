require 'rails_helper'

RSpec.describe NetworkJob, type: :job do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, user: @user, entries_count: 0)
    create(:query, dataset: @dataset, q: "uid:\"#{WORKING_UIDS[2]}\"")
    @task = create(:task, dataset: @dataset)

    # The network code loads the English stop list
    @stop_list = create(:stop_list)

    # Don't run the analyses
    nodes = [double(RLetters::Analysis::Network::Node, id: 1, words: 'test'),
             double(RLetters::Analysis::Network::Node, id: 2, words: 'yes')]
    edges = [double(RLetters::Analysis::Network::Edge,
                    one: 'test', two: 'yes', weight: 1)]
    mock = double(RLetters::Analysis::Network::Graph,
                  nodes: nodes, edges: edges, max_edge_weight: 2)
    allow(RLetters::Analysis::Network::Graph).to receive(:new) do |hash|
      hash[:progress].call(100)
      mock
    end
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
        word: 'diseases')
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
      expect(hash['word']).to eq('diseases')
      expect(hash['d3_links'][0]['strength']).to eq(0.5)
    end
  end
end
