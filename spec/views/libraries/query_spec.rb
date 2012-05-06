# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "libraries/query" do
  
  login_user
  
  context 'when libraries are assigned' do
    before(:each) do
      assign(:libraries, [ { :name => 'University of Notre Dame', 
        :url => 'http://findtext.library.nd.edu:8889/ndu_local?' } ])
      render
    end
    
    it 'has a form for adding the library' do
      rendered.should have_selector('form')
    end
    
    it 'has an input field for the library name' do
      rendered.should have_selector("input[value='University of Notre Dame']")
    end
    
    it 'has an input field for the library URL' do
      rendered.should have_selector("input[value='http://findtext.library.nd.edu:8889/ndu_local?']")
    end
  end
  
  context 'when no libraries are assigned' do
    before(:each) do
      assign(:libraries, [ ])
      render
    end
    
    it 'has no library forms' do
      rendered.should_not have_selector('form')
    end
  end
  
end
