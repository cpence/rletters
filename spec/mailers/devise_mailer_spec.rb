# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe DeviseMailer, type: :mailer do
  # I've customized this view, so here's a spec for it
  describe '#reset_password_instructions' do
    before(:example) do
      @user = build(:user, reset_password_token: 'resettoken')
      @mail = DeviseMailer.reset_password_instructions(@user, 'resettoken')
    end

    it 'sets the to e-mail' do
      expect(@mail.to).to eq([@user.email])
    end

    it 'has a link to the reset password form' do
      expect(@mail.body.encoded).to include(edit_user_password_url(@user, reset_password_token: 'resettoken'))
    end

    it 'mentions the user name' do
      expect(@mail.body.encoded).to include(@user.name)
    end
  end
end
