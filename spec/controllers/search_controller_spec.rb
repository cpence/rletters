require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  describe '#index' do
    context 'with empty search results' do
      before(:example) do
        get :index, q: 'fail'
      end

      it 'loads successfully' do
        expect(response).to be_success
      end
    end

    context 'with search results' do
      before(:example) do
        get :index
      end

      it 'assigns the search result' do
        expect(assigns(:result)).to be
      end
    end
  end

  describe '#advanced' do
    it 'loads successfully' do
      get :advanced
      expect(response).to be_success
    end
  end
end
