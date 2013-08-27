# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'libraries/delete' do

  before(:each) do
    @user = FactoryGirl.create(:user)
    allow(view).to receive(:current_user).and_return(@user)
    allow(view).to receive(:user_signed_in?).and_return(true)

    @library = FactoryGirl.create(:library, user: @user)
    assign(:library, @library)
    render
  end

  it 'has a form to delete the library' do
    expect(rendered).to have_tag("form[action='#{library_path(@library)}']")
    expect(rendered).to have_tag('input[name=_method][value=delete]')
  end

  it 'has a confirm button' do
    expect(rendered).to have_tag('input[name=commit]')
  end

  it 'has a cancel button' do
    expect(rendered).to have_tag('input[name=cancel]')
  end

end
