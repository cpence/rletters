require 'rails_helper'

RSpec.describe RLetters::Documents::Authors do
  describe '.from_list' do
    it 'calls the appropriate constructor' do
      expect(RLetters::Documents::Author).to receive(:new).with(full: 'A One').and_call_original
      expect(RLetters::Documents::Author).to receive(:new).with(full: 'B Two').and_call_original

      described_class.from_list('A One, B Two')
    end

    it 'returns an empty array with a nil string' do
      expect(described_class.from_list(nil)).to eq([])
    end

    it 'returns an empty array with a blank string' do
      expect(described_class.from_list('   ')).to eq([])
    end
  end

  describe '#to_s' do
    it 'returns as expected' do
      expect(described_class.from_list('A One, B Two').to_s).to eq('A One, B Two')
    end
  end
end
