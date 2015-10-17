require 'rails_helper'

RSpec.describe RLetters::Analysis::Frequency::Base do
  context 'when the quick-out is available' do
    before(:example) do
      @user = create(:user)
      @dataset = create(:full_dataset, entries_count: 10, working: true,
                                       user: @user)

      @analyzer = described_class.call(dataset: @dataset)
    end

    it 'returns a FromTF object' do
      expect(@analyzer).to be_a(RLetters::Analysis::Frequency::FromTF)
    end
  end

  context 'when the quick-out is not available' do
    before(:example) do
      @user = create(:user)
      @dataset = create(:full_dataset, entries_count: 10, working: true,
                                       user: @user)

      @analyzer = described_class.call(dataset: @dataset,
                                       'num_blocks' => 3,
                                       'ngrams' => 2)
    end

    it 'returns a FromPosition object' do
      expect(@analyzer).to be_a(RLetters::Analysis::Frequency::FromPosition)
    end
  end
end
