require 'spec_helper'

RSpec.describe ApplicationController, type: :request do
  describe '#after_sign_in_path_for' do
    context 'with a regular user' do
      before(:example) do
        @user = create(:user)
      end

      it 'redirects to the root path on login' do
        post(user_session_path,
             user: { email: @user.email,
                     password: @user.password,
                     password_confirmation: @user.password })
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to be
        expect(flash[:alert]).not_to be
      end
    end

    context 'with an admin user' do
      before(:example) do
        @user = create(:administrator)
      end

      it 'redirects to the admin root on login' do
        post(administrator_session_path,
             administrator: { email: @user.email,
                              password: @user.password,
                              password_confirmation: @user.password })
        expect(response).to redirect_to(admin_root_path)
        expect(flash[:notice]).to be
        expect(flash[:alert]).not_to be
      end
    end
  end

  describe '#after_sign_out_path_for' do
    before(:example) do
      @user = create(:user)
      post(user_session_path,
           user: { email: @user.email,
                   password: @user.password,
                   password_confirmation: @user.password })
    end

    it 'redirects to the root path on logout' do
      # This would be a delete request, but we've overridden it.
      get(destroy_user_session_path)
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to be
      expect(flash[:alert]).not_to be
    end
  end
end
