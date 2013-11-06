# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ApplicationController do

  describe '#after_sign_in_path_for' do
    context 'with a regular user' do
      before(:each) do
        @user = FactoryGirl.create(:user)
      end

      it 'redirects to the root path on login' do
        post(user_session_path(trailing_slash: true),
             user: { email: @user.email,
                     password: @user.password,
                     password_confirmation: @user.password })
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to be
        expect(flash[:alert]).not_to be
      end
    end

    context 'with an admin user' do
      before(:each) do
        @user = FactoryGirl.create(:admin_user)
      end

      it 'redirects to the admin root on login' do
        post(admin_user_session_path(trailing_slash: true),
             admin_user: { email: @user.email,
                           password: @user.password,
                           password_confirmation: @user.password })
        expect(response).to redirect_to(admin_root_path)
        expect(flash[:notice]).to be
        expect(flash[:alert]).not_to be
      end
    end
  end

  describe '#after_sign_out_path_for' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      post(user_session_path(trailing_slash: true),
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
