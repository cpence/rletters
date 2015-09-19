require 'rails_helper'

RSpec.describe NamedEntitiesJob, type: :job do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, user: @user)
    @task = create(:task, dataset: @dataset)

    @old_path = Admin::Setting.nlp_tool_path
    Admin::Setting.nlp_tool_path = 'stubbed'

    @entities = build(:named_entities)
    allow(RLetters::Analysis::NLP).to receive(:named_entities).and_return(@entities)
  end

  after(:example) do
    Admin::Setting.nlp_tool_path = @old_path
  end

  it_should_behave_like 'an analysis job'

  describe '.available?' do
    it 'is true with NLP available' do
      expect(described_class.available?).to be true
    end

    it 'is false with no NLP available' do
      Admin::Setting.nlp_tool_path = nil
      expect(described_class.available?).to be false
    end
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(described_class.num_datasets).to eq(1)
    end
  end

  context 'when all parameters are valid' do
    before(:example) do
      described_class.new.perform(@task)
      @task.reload
    end

    it 'names the task correctly' do
      expect(@task.name).to eq('Extract references to proper names')
    end

    it 'creates two files' do
      expect(@task.files.count).to eq(2)
      expect(@task.file_for('application/json')).not_to be_nil
      expect(@task.file_for('text/csv')).not_to be_nil
    end

    it 'creates good JSON' do
      data = JSON.load(@task.file_for('application/json').result.file_contents(:original))
      expect(data).to be_a(Hash)
    end

    it 'fills in some values' do
      hash = JSON.load(@task.file_for('application/json').result.file_contents(:original))
      refs = hash['data']

      expect(refs).to include('PERSON')
      expect(refs['PERSON']).to be_an(Array)
      expect(refs['PERSON']).not_to be_empty
    end
  end
end
