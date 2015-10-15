require 'spec_helper'

RSpec.describe RLetters::Analysis::NamedEntities do
  before(:example) do
    @old_path = ENV['NLP_TOOL_PATH']
    ENV['NLP_TOOL_PATH'] = 'stubbed'

    @entities = build(:named_entities)
    expect(RLetters::Analysis::NLP).to receive(:named_entities).and_return(@entities)

    @user = create(:user)
    @dataset = create(:full_dataset, working: true, user: @user)

    @called_sub_100 = false
    @called_100 = false
    @refs = described_class.call(
      dataset: @dataset,
      progress: lambda do |p|
        if p < 100
          @called_sub_100 = true
        else
          @called_100 = true
        end
      end)
  end

  after(:example) do
    ENV['NLP_TOOL_PATH'] = @old_path
  end

  describe '#entity_references' do
    it 'works as expected' do
      expect(@refs['PERSON']).to include('Harry')
    end
  end

  describe '#progress' do
    it 'calls the progress function with under and equal to 100' do
      expect(@called_sub_100).to be true
      expect(@called_100).to be true
    end
  end
end
