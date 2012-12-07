# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "libraries/edit" do
  
  before(:each) do
    @user = FactoryGirl.create(:user)
    view.stub(:current_user) { @user }
    view.stub(:user_signed_in?) { true }

    @library = FactoryGirl.create(:library, :user => @user)
    assign(:library, @library)    
    render
  end
  
  it 'has a filled-in name field' do
    rendered.should have_selector("input[name='library[name]'][value=#{@library.name}]")
  end
  
  it 'has a filled-in URL field' do
    rendered.should have_selector("input[name='library[url]'][value='#{@library.url}']")
  end
  
end
