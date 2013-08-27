require 'spec_helper'

describe 'users/registrations/new' do
  before(:each) do
    @user = mock_model(User, remember_me: true)
    allow(@view).to receive(:resource).and_return(@user)
    allow(@view).to receive(:resource_name).and_return('user')

    @devise_mapping = double(rememberable?: true, registerable?: true, recoverable?: true, confirmable?: false, lockable?: false, omniauthable?: false)
    allow(@view).to receive(:devise_mapping).and_return(@devise_mapping)

    allow(@view).to receive(:devise_error_messages!).and_return('')

    render
  end

  it 'has a field for the e-mail' do
    expect(rendered).to have_tag('input[name="user[email]"]')
  end

  it 'has a field for the password' do
    expect(rendered).to have_tag('input[name="user[password]"]')
  end

  it 'has a field for the password confirmation' do
    expect(rendered).to have_tag('input[name="user[password_confirmation]"]')
  end

  it 'has a field for the langauge' do
    expect(rendered).to have_tag('select[name="user[language]"]')
  end

  it 'has an option for a few languages' do
    expect(rendered).to have_tag('option[value="es"]', text: 'Spanish')
    expect(rendered).to have_tag('option[value="en"]', text: 'English')
  end

  it 'has a field for the timezone' do
    expect(rendered).to have_tag('select[name="user[timezone]"]')
  end

  it 'has an option for a few timezones' do
    expect(rendered).to have_tag('option[value="Quito"]')
    expect(rendered).to have_tag('option[value="Central Time (US & Canada)"]')
  end
end
