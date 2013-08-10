# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'libraries/edit' do

  before(:each) do
    @user = FactoryGirl.create(:user)
    allow(view).to receive(:current_user).and_return(@user)
    allow(view).to receive(:user_signed_in?).and_return(true)

    @library = FactoryGirl.create(:library, user: @user)
    assign(:library, @library)
    render
  end

  it 'has a filled-in name field' do
    expect(rendered).to have_tag("input[name='library[name]'][value=#{@library.name}]")
  end

  it 'has a filled-in URL field' do
    expect(rendered).to have_tag("input[name='library[url]'][value='#{@library.url}']")
  end

end
