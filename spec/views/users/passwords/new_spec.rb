require 'spec_helper'

describe 'users/passwords/new' do
  before(:each) do
    @user = mock_model(User, remember_me: true)
    allow(@view).to receive(:resource).and_return(@user)
    allow(@view).to receive(:resource_name).and_return('user')

    @devise_mapping = double(rememberable?: true, registerable?: true, recoverable?: true, confirmable?: false, lockable?: false, omniauthable?: false)
    allow(@view).to receive(:devise_mapping).and_return(@devise_mapping)

    allow(@view).to receive(:devise_error_messages!).and_return('')

    render
  end

  it 'has a field for e-mail' do
    expect(rendered).to have_tag('input[name="user[email]"]')
  end
end
