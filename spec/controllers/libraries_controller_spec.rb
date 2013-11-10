# -*- encoding : utf-8 -*-
require 'spec_helper'

describe LibrariesController do

  before(:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user

    @library = FactoryGirl.create(:library, user: @user)
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
               library: FactoryGirl.attributes_for(:library, user: @user)
        }.to change { @user.libraries.count }.by(1)
      end

      it 'redirects to the user page' do
        post :create,
             library: FactoryGirl.attributes_for(:library, user: @user)
        expect(response).to redirect_to(edit_user_registration_path)
      end
    end

    context 'when library is invalid' do
      it 'does not create a library' do
        expect {
          post :create,
               library: FactoryGirl.attributes_for(:library,
                                                   url: 'what:nope',
                                                   user: @user)
        }.to_not change { @user.libraries.count }
      end

      it 'renders the new form' do
        post :create,
             library: FactoryGirl.attributes_for(:library,
                                                 url: 'what:nope',
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
        put :update, id: @library.to_param, library: { name: 'Woo' }
        @library.reload
        expect(@library.name).to eq('Woo')
      end

      it 'redirects to the user page' do
        put :update, id: @library.to_param, library: { name: 'Woo' }
        expect(response).to redirect_to(edit_user_registration_path)
      end
    end

    context 'when library is invalid' do
      it 'does not edit the library' do
        put :update, id: @library.to_param, library: { url: 'what:nope' }

        @library.reload
        expect(@library.url).not_to eq('1234%%#$')
      end

      it 'renders the edit form' do
        put :update, id: @library.to_param, library: { url: 'what:nope' }
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
        stub_connection(/worldcatlibraries.org/, 'worldcat_no_libraries')
        get :query
        expect(assigns(:libraries)).to be_empty
      end
    end

    context 'when libraries are returned' do
      it 'assigns the libraries' do
        stub_connection(/worldcatlibraries.org/, 'worldcat_notre_dame')
        get :query
        expect(assigns(:libraries).count).to eq(1)
      end
    end

    context 'when WorldCat times out' do
      it 'assigns no libraries' do
        stub_request(:any,
                     %r{worldcatlibraries.org/registry/lookup.*}).to_timeout
        get :query
        expect(assigns(:libraries)).to be_empty
      end
    end
  end

end
