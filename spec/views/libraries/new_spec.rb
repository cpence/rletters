# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "libraries/new" do
  
  before(:each) do
    @user = FactoryGirl.create(:user)
    view.stub(:current_user) { @user }
    view.stub(:user_signed_in?) { true }

    assign(:library, @user.libraries.build)    
    render
  end
  
  it 'has a form field for name' do
    rendered.should have_tag("input[name='library[name]']")
  end
  
  it 'has a form field for URL' do
    rendered.should have_tag("input[name='library[url]']")
  end
  
end
