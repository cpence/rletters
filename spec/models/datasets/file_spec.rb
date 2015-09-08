require 'rails_helper'

RSpec.describe Datasets::File, type: :model do
  describe '#valid?' do
    context 'when no description is specified' do
      before(:example) do
        @file = build_stubbed(:file, description: nil)
      end

      it 'is not valid' do
        expect(@file).not_to be_valid
      end
    end

    context 'when no task is specified' do
      before(:example) do
        @file = build_stubbed(:file, task: nil)
      end

      it 'is not valid' do
        expect(@file).not_to be_valid
      end
    end

    context 'when all parameters are valid' do
      before(:example) do
        @file = create(:file)
      end

      it 'is valid' do
        expect(@file).to be_valid
      end
    end
  end
end
