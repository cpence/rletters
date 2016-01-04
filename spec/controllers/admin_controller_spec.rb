require 'rails_helper'

RSpec.describe AdminController, type: :controller do
  context 'when logged in' do
    before(:example) do
      @admin = create(:administrator)
      sign_in @admin
    end

    describe '#index' do
      it 'loads successfully' do
        get :index
        expect(response).to be_success
      end
    end
  end

  context 'when not logged in' do
    describe '#index' do
      it 'redirects to admin sign-in' do
        get :index
        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    describe '#collection_index' do
      it 'redirects to admin sign-in' do
        get :collection_index, model: 'user'
        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    describe '#item_index' do
      it 'redirects to admin sign-in' do
        user = create(:user)

        get :item_index, model: 'user', id: user.to_param
        expect(response).to redirect_to(new_administrator_session_path)
      end
    end

    describe '#item_delete' do
      it 'redirects to admin sign-in' do
        user = create(:user)

        get :item_index, model: 'user', id: user.to_param
        expect(response).to redirect_to(new_administrator_session_path)
      end

      it 'does no deleting' do
        user = create(:user)

        expect {
          get :item_index, model: 'user', id: user.to_param
        }.not_to change { User.count }
      end
    end
  end
end
