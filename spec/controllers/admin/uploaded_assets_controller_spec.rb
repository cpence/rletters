# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin::UploadedAssetsController do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in :admin_user, @admin_user
  end

  describe '#index' do
    before(:each) do
      get :index
    end

    it 'loads successfully' do
      response.should be_success
    end

    it 'includes some of the uploaded assets' do
      response.body.should include('Splash Screen (320x460)')
      response.body.should include('App Icon (precomposed, 57x57)')
    end
  end

  describe '#show' do
    before(:each) do
      @asset = UploadedAsset.find_by!(name: 'apple-touch-icon-precomposed-low')
      get :show, id: @asset.to_param
    end

    it 'loads successfully' do
      response.should be_success
    end

    it 'shows the asset image on the page' do
      response.body.should match(/<img[^>]*src="#{Regexp.escape(@asset.file.url)}"[^>]*\/>/)
    end
  end

  describe '#edit' do
    before(:each) do
      @asset = UploadedAsset.find_by!(name: 'apple-touch-icon-precomposed-low')
      get :edit, id: @asset.to_param
    end

    it 'loads successfully' do
      response.should be_success
    end

    it 'has an upload button for the asset' do
      response.body.should have_tag('input[name="uploaded_asset[file]"]')
    end
  end

end
