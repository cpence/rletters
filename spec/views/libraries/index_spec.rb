# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'libraries/index' do

  before(:each) do
    @user = FactoryGirl.create(:user)
    allow(view).to receive(:current_user).and_return(@user)
    allow(view).to receive(:user_signed_in?).and_return(true)

    @library = FactoryGirl.create(:library, user: @user)
    @user.libraries.reload

    assign(:libraries, @user.libraries)
    render
  end

  it 'has a link to edit the library' do
    expect(rendered).to have_tag("a[href='#{edit_library_path(@library)}']", text: @library.name)
  end

  it 'has a link to delete the library' do
    expect(rendered).to have_tag("a[href='#{delete_library_path(@library)}']")
  end

  it 'has a link to add a new library' do
    expect(rendered).to have_tag("a[href='#{new_library_path}']")
  end

  it 'has a link to query local libraries' do
    expect(rendered).to have_tag("a[href='#{query_libraries_path}']")
  end

end
