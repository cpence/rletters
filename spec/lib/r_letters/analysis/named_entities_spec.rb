# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Analysis::NamedEntities do
  before(:each) do
    @old_path = Admin::Setting.nlp_tool_path
    Admin::Setting.nlp_tool_path = 'stubbed'

    @entities = build(:named_entities)
    expect(RLetters::Analysis::NLP).to receive(:named_entities).and_return(@entities)
  end

  after(:each) do
    Admin::Setting.nlp_tool_path = @old_path
  end

  describe '#entity_references' do
    before(:each) do
      @dataset = build(:full_dataset, stub: true, user: @user)
      @analyzer = described_class.new(@dataset)
      @analyzer.call
    end

    it 'works as expected' do
      expect(@analyzer.entity_references['PERSON']).to include('Nam')
    end
  end

  describe '#progress' do
    it 'calls the progress function with under and equal to 100' do
      called_sub_100 = false
      called_100 = false

      @dataset = build(:full_dataset, stub: true, user: @user)
      @analyzer = described_class.new(@dataset, ->(p) {
        if p < 100
          called_sub_100 = true
        else
          called_100 = true
        end
      })

      @analyzer.call

      expect(called_sub_100).to be true
      expect(called_100).to be true
    end
  end
end
