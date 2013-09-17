# -*- encoding : utf-8 -*-
require "spec_helper"

describe Devise::Mailer do
  # I've customized this view, so here's a spec for it
  describe '#reset_password_instructions' do
    before(:each) do
      @user = mock_model(User,
                         email: 'user@user.com',
                         reset_password_token: 'resettoken')
      @mail = Devise::Mailer::reset_password_instructions(@user)
    end

    it 'sets the to e-mail' do
      expect(@mail.to).to eq(['user@user.com'])
    end

    it 'has a link to the reset password form' do
      expect(@mail.body.encoded).to include(edit_user_password_url(@user, reset_password_token: 'resettoken'))
    end

    it 'mention the user email' do
      expect(@mail.body.encoded).to include('user@user.com')
    end
  end
end
