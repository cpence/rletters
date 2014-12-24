require 'spec_helper'

RSpec.describe Datasets::Entry, type: :model do
  describe '#valid?' do
    context 'when no uid is specified' do
      before(:example) do
        @entry = build_stubbed(:entry, uid: nil)
      end

      it 'is not valid' do
        expect(@entry).not_to be_valid
      end
    end

    context 'when a good uid is specified' do
      before(:example) do
        @entry = create(:entry)
      end

      it 'is valid' do
        expect(@entry).to be_valid
      end
    end
  end
end
