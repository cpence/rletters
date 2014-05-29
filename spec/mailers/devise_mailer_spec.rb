# -*- encoding : utf-8 -*-
require 'spec_helper'

describe DeviseMailer do
  # I've customized this view, so here's a spec for it
  describe '#reset_password_instructions' do
    before(:each) do
      @user = mock_model(User,
                         name: 'Name of the User',
                         email: 'user@user.com',
                         reset_password_token: 'resettoken')
      @mail = DeviseMailer.reset_password_instructions(@user, 'resettoken')
    end

    it 'sets the to e-mail' do
      expect(@mail.to).to eq(['user@user.com'])
    end

    it 'has a link to the reset password form' do
      expect(@mail.body.encoded).to include(edit_user_password_url(@user, reset_password_token: 'resettoken'))
    end

    it 'mentions the user name' do
      expect(@mail.body.encoded).to include('Name of the User')
    end
  end
end
