# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'libraries/new' do

  before(:each) do
    @user = FactoryGirl.create(:user)
    allow(view).to receive(:current_user).and_return(@user)
    allow(view).to receive(:user_signed_in?).and_return(true)

    assign(:library, @user.libraries.build)
    render
  end

  it 'has a form field for name' do
    expect(rendered).to have_tag('input[name="library[name]"]')
  end

  it 'has a form field for URL' do
    expect(rendered).to have_tag('input[name="library[url]"]')
  end

end
