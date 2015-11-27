require 'spec_helper'
require_relative './shared_examples'

RSpec.describe RLetters::Analysis::Collocation do
  context 'without the NLP tool available' do
    before(:example) do
      @old_path = ENV['NLP_TOOL_PATH']
      ENV['NLP_TOOL_PATH'] = nil

      @user = create(:user)
      @dataset = create(:full_dataset, working: true)
    end

    after(:example) do
      ENV['NLP_TOOL_PATH'] = @old_path
    end

    it 'analyzes with mutual information instead' do
      @result = described_class.call(scoring: :parts_of_speech,
                                     dataset: @dataset,
                                     num_pairs: 10)
      expect(@result.scoring).to eq(:mutual_information)
    end
  end

  context 'with the NLP tool available' do
    before(:example) do
      @old_path = ENV['NLP_TOOL_PATH']
      ENV['NLP_TOOL_PATH'] = 'stubbed'

      @words = build(:parts_of_speech)
      expect(RLetters::Analysis::NLP).to receive(:parts_of_speech).at_least(:once).and_return(@words)
    end

    after(:example) do
      ENV['NLP_TOOL_PATH'] = @old_path
    end

    it_should_behave_like 'a collocation analyzer', :parts_of_speech
  end
end
