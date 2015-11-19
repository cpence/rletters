require 'rails_helper'

RSpec.describe Datasets::Query, type: :model do
  describe '#valid?' do
    context 'when no def_type is specified' do
      before(:example) do
        @query = build_stubbed(:query, def_type: nil)
      end

      it 'is not valid' do
        expect(@query).not_to be_valid
      end
    end

    context 'when a good def_type is specified' do
      before(:example) do
        @query = create(:query)
      end

      it 'is valid' do
        expect(@query).to be_valid
      end
    end
  end
end
