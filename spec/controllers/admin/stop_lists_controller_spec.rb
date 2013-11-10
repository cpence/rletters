# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin::StopListsController do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:each) do
    @administrator = FactoryGirl.create(:administrator)
    sign_in :administrator, @administrator
  end

  describe '#index' do
    before(:each) do
      get :index
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'includes one of the stop lists' do
      expect(response.body).to include('French')
    end
  end

  describe '#show' do
    before(:each) do
      @list = StopList.find_by!(language: 'fr')
      get :show, id: @list.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end
  end

  describe '#edit' do
    before(:each) do
      @list = StopList.find_by!(language: 'fr')
      get :edit, id: @list.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'has a textarea field for the list' do
      expect(response.body).to have_selector('textarea[name="stop_list[list]"]')
    end
  end

end
