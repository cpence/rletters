require 'spec_helper'

RSpec.describe Admin::AdminUploadedAssetsController, type: :controller do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:example) do
    @asset = create(:uploaded_asset)
    @administrator = create(:administrator)
    sign_in :administrator, @administrator
  end

  describe '#index' do
    before(:example) do
      get :index
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'includes the uploaded assets in the list' do
      expect(response.body).to satisfy do |s|
        s.include?(@asset.name) || s.include?('The Friendly Name')
      end
    end
  end

  describe '#show' do
    before(:example) do
      get :show, id: @asset.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'shows the asset image on the page' do
      expect(response.body).to match(%r{<img[^>]*src="/workflow/image/#{@asset.to_param}\?})
    end
  end

  describe '#edit' do
    before(:example) do
      get :edit, id: @asset.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'has an upload button for the asset' do
      expect(response.body).to have_selector('input[name="admin_uploaded_asset[file]"]')
    end
  end
end
