require 'spec_helper'
require_relative './shared_examples'

RSpec.describe RLetters::Analysis::Collocation::PartsOfSpeech do
  context 'without the NLP tool available' do
    before(:context) do
      @old_path = Admin::Setting.nlp_tool_path
      Admin::Setting.nlp_tool_path = nil

      @user = create(:user)
      @dataset = create(:full_dataset, working: true)
    end

    after(:context) do
      Admin::Setting.nlp_tool_path = @old_path
    end

    it 'raises an error when called' do
      expect {
        @grams = described_class.new(@dataset, 10).call
      }.to raise_error(ArgumentError)
    end
  end

  context 'with the NLP tool available' do
    before(:example) do
      @old_path = Admin::Setting.nlp_tool_path
      Admin::Setting.nlp_tool_path = 'stubbed'

      @words = build(:parts_of_speech)
      expect(RLetters::Analysis::NLP).to receive(:parts_of_speech).at_least(:once).and_return(@words)
    end

    after(:example) do
      Admin::Setting.nlp_tool_path = @old_path
    end

    it_should_behave_like 'a collocation analyzer (before example)'
  end
end
