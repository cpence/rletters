# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'libraries/query' do

  before(:each) do
    @user = FactoryGirl.create(:user)
    allow(view).to receive(:current_user).and_return(@user)
    allow(view).to receive(:user_signed_in?).and_return(true)
  end

  context 'when libraries are assigned' do
    before(:each) do
      assign(:libraries, [{
        name: 'University of Notre Dame',
        url: 'http://findtext.library.nd.edu:8889/ndu_local?'
      }])
      render
    end

    it 'has a form for adding the library' do
      expect(rendered).to have_tag('form')
    end

    it 'has an input field for the library name' do
      expect(rendered).to have_tag('input[value="University of Notre Dame"]')
    end

    it 'has an input field for the library URL' do
      expect(rendered).to have_tag('input[value="http://findtext.library.nd.edu:8889/ndu_local?"]')
    end
  end

  context 'when no libraries are assigned' do
    before(:each) do
      assign(:libraries, [])
      render
    end

    it 'has no library forms' do
      expect(rendered).not_to have_tag('form')
    end
  end

end
