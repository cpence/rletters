# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe Jobs::Analysis::NamedEntities do
  it_should_behave_like 'an analysis job'

  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true, user: @user)
    @task = create(:analysis_task, dataset: @dataset)

    @old_path = Admin::Setting.nlp_tool_path
    Admin::Setting.nlp_tool_path = 'stubbed'

    @entities = build(:named_entities)
    allow(RLetters::Analysis::NLP).to receive(:named_entities).and_return(@entities)
  end

  after(:example) do
    Admin::Setting.nlp_tool_path = @old_path
  end

  describe '.download?' do
    it 'is false' do
      expect(Jobs::Analysis::NamedEntities.download?).to be false
    end
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(Jobs::Analysis::NamedEntities.num_datasets).to eq(1)
    end
  end

  context 'when all parameters are valid' do
    before(:example) do
      Jobs::Analysis::NamedEntities.perform(
        '123',
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        task_id: @task.to_param)
      @task.reload
    end

    it 'names the task correctly' do
      expect(@task.name).to eq('Extract references to proper names')
    end

    it 'creates good JSON' do
      data = JSON.load(@task.result.file_contents(:original))
      expect(data).to be_a(Hash)
    end

    it 'fills in some values' do
      hash = JSON.load(@task.result.file_contents(:original))
      refs = hash['data']

      expect(refs).to include('PERSON')
      expect(refs['PERSON']).to be_an(Array)
      expect(refs['PERSON']).not_to be_empty
    end
  end
end
