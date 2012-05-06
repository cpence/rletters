# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "users/new" do
  
  context 'when new user is invalid' do
    before(:each) do
      user = FactoryGirl.build(:user, :identifier => 'notaurl')
      user.save
      
      assign(:new_user, user)
      render
    end
    
    it 'shows validation errors' do
      rendered.should have_selector('form ul[data-theme=e]')
    end
  end
  
  context 'when a default language is provided (with country)' do
    before(:each) do
      view.stub(:get_user_language).and_return('es-MX')
      user = User.new
      
      assign(:new_user, user)
      render
    end
    
    it "selects the user's language on the form" do
      rendered.should have_selector('select[id=user_language]') do |items|
        items[0].should have_selector('option[value=es-MX][selected]')
      end
    end
  end
  
  context 'when a default language is provided (without country)' do
    before(:each) do
      view.stub(:get_user_language).and_return('es')
      user = User.new
      
      assign(:new_user, user)
      render
    end
    
    it "selects the user's language on the form" do
      rendered.should have_selector('select[id=user_language]') do |items|
        items[0].should have_selector('option[value=es][selected]')
      end
    end
  end
  
end
