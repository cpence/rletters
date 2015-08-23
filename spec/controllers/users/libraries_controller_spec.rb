require 'rails_helper'

RSpec.describe Users::LibrariesController, type: :controller do
  before(:example) do
    @user = create(:user)
    sign_in @user

    @library = create(:library, user: @user)
  end

  describe '#index' do
    it 'loads successfully' do
      get :index
      expect(response).to be_success
    end
  end

  describe '#new' do
    it 'loads successfully' do
      get :new
      expect(response).to be_success
    end
  end

  describe '#create' do
    context 'when library is valid' do
      it 'creates a library' do
        expect {
          post :create,
               users_library: attributes_for(:library, user: @user)
        }.to change { @user.libraries.count }.by(1)
      end

      it 'redirects to the user page' do
        post :create,
             users_library: attributes_for(:library, user: @user)
        expect(response).to redirect_to(edit_user_registration_path)
      end
    end

    context 'when library is invalid' do
      it 'does not create a library' do
        expect {
          post :create,
               users_library: attributes_for(:library, url: 'what:nope',
                                                       user: @user)
        }.to_not change { @user.libraries.count }
      end

      it 'renders the new form' do
        post :create,
             users_library: attributes_for(:library, url: 'what:nope',
                                                     user: @user)
        expect(response).not_to redirect_to(edit_user_registration_path)
      end
    end
  end

  describe '#edit' do
    it 'loads successfully' do
      get :edit, id: @library.to_param
      expect(response).to be_success
    end
  end

  describe '#update' do
    context 'when library is valid' do
      it 'edits the library' do
        put :update, id: @library.to_param, users_library: { name: 'Woo' }
        @library.reload
        expect(@library.name).to eq('Woo')
      end

      it 'redirects to the user page' do
        put :update, id: @library.to_param, users_library: { name: 'Woo' }
        expect(response).to redirect_to(edit_user_registration_path)
      end
    end

    context 'when library is invalid' do
      it 'does not edit the library' do
        put :update, id: @library.to_param, users_library: { url: 'what:nope' }

        @library.reload
        expect(@library.url).not_to eq('1234%%#$')
      end

      it 'renders the edit form' do
        put :update, id: @library.to_param, users_library: { url: 'what:nope' }
        expect(response).not_to redirect_to(edit_user_registration_path)
      end
    end
  end

  describe '#destroy' do
    it 'deletes the library' do
      expect {
        delete :destroy, id: @library.to_param
      }.to change { @user.libraries.count }.by(-1)
    end

    it 'redirects to the user page' do
      delete :destroy, id: @library.to_param, cancel: true
      expect(response).to redirect_to(edit_user_registration_path)
    end
  end

  describe '#query' do
    context 'when no libraries are returned' do
      it 'assigns no libraries' do
        stub_connection(/worldcat.org/, 'worldcat_no_libraries')
        get :query
        expect(assigns(:libraries)).to be_empty
      end
    end

    context 'when libraries are returned' do
      it 'assigns the libraries' do
        stub_connection(/worldcat.org/, 'worldcat_notre_dame')
        get :query
        expect(assigns(:libraries).size).to eq(1)
      end
    end

    context 'when WorldCat times out' do
      it 'assigns no libraries' do
        stub_request(:any,
                     %r{worldcat.org/registry/lookup.*}).to_timeout
        get :query
        expect(assigns(:libraries)).to be_empty
      end
    end
  end
end
