# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'info/index' do

  before(:each) do
    assign(:database_size, 100)
  end

  context 'when no user is logged in' do
    before(:each) do
      allow(@view).to receive(:current_user).and_return(nil)
      render
    end

    it 'links to the tutorial' do
      expect(rendered).to include(info_tutorial_path)
    end

    it 'links to the login page' do
      expect(rendered).to include(user_registration_path)
    end

    it 'links to the search page' do
      expect(rendered).to include(search_path)
    end
  end

  context 'when a user is logged in' do
    before(:each) do
      @user = mock_model(User, datasets: [])
      allow(@view).to receive(:current_user).and_return(@user)
      render
    end

    it 'links to the search page' do
      expect(rendered).to include(search_path)
    end

    it 'links to the datasets page' do
      expect(rendered).to include(datasets_path)
    end

    it 'links to the account page' do
      expect(rendered).to include(edit_user_registration_path)
    end

    it 'shows the size of the database' do
      expect(rendered).to include('The database contains 100 documents')
    end

    it 'links to the tutorial' do
      expect(rendered).to include(info_tutorial_path)
    end

    it 'links to the FAQ' do
      expect(rendered).to include(info_faq_path)
    end
  end

end
