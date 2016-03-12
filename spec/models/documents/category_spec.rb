require 'rails_helper'

RSpec.describe Documents::Category, type: :model do
  before(:example) do
    @category = create(:category)
  end

  describe '#enabled?' do
    it 'works when enabled' do
      expect(@category.enabled?(categories: [@category.to_param])).to be
    end

    it 'works when disabled' do
      expect(@category.enabled?({})).not_to be
    end
  end

  describe '#toggle_params' do
    context 'when enabled' do
      it 'works' do
        params = @category.toggle_search_params(categories: [@category.to_param])
        expect(params[:categories]).not_to be
      end
    end

    context 'when disabled' do
      it 'works' do
        params = @category.toggle_search_params({})
        expect(params[:categories]).to eq([@category.to_param])
      end
    end
  end
end
