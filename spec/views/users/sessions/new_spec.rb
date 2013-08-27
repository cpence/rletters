# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'users/sessions/new' do
  before(:each) do
    @user = mock_model(User, remember_me: true)
    allow(@view).to receive(:resource).and_return(@user)
    allow(@view).to receive(:resource_name).and_return('user')

    @devise_mapping = double(rememberable?: true, registerable?: true, recoverable?: true, confirmable?: false, lockable?: false, omniauthable?: false)
    allow(@view).to receive(:devise_mapping).and_return(@devise_mapping)

    render
  end

  it 'has a field for the e-mail' do
    expect(rendered).to have_tag('input[name="user[email]"]')
  end

  it 'has a field for the password' do
    expect(rendered).to have_tag('input[name="user[password]"]')
  end

  it 'has a link to the sign-up form' do
    expect(rendered).to include(new_user_registration_path)
  end
end
