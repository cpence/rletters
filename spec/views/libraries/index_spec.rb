# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "libraries/index" do
  
  login_user
  
  before(:each) do
    @library = FactoryGirl.create(:library, :user => @user)
    @user.libraries.reload
    
    assign(:libraries, @user.libraries)    
    render
  end
  
  it 'has a link to edit the library' do
    rendered.should have_selector("a[href='#{edit_user_library_path(@library)}']", :content => @library.name)
  end
  
  it 'has a link to delete the library' do
    rendered.should have_selector("a[href='#{delete_user_library_path(@library)}']")
  end
  
  it 'has a link to add a new library' do
    rendered.should have_selector("a[href='#{new_user_library_path}']")
  end
  
  it 'has a link to query local libraries' do
    rendered.should have_selector("a[href='#{query_user_libraries_path}']")
  end
  
end
