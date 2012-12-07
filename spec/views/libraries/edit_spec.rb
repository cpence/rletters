# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "libraries/edit" do
  
  before(:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user

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
