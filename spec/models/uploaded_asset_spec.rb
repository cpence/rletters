# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UploadedAsset do

  describe '#valid?' do
    context 'when no name spcified' do
      before(:each) do
        @asset = FactoryGirl.build(:uploaded_asset, name: nil)
      end

      it 'is not valid' do
        @asset.should_not be_valid
      end
    end

    context 'when all parameters are valid' do
      before(:each) do
        @asset = FactoryGirl.build(:uploaded_asset)
      end

      it 'is valid' do
        @asset.should be_valid
      end
    end
  end

  describe '#friendly_name' do
    before(:each) do
      @asset = FactoryGirl.create(:uploaded_asset)
    end

    it 'returns the plain name with no translation, friendly name with translation' do
      # There's no way to *delete* a translation from the I18n backend, so
      # we have to do this in one test to make sure they're in order
      @asset.friendly_name.should eq(@asset.name)

      I18n.backend.store_translations :en, uploaded_assets:
        { @asset.name.to_sym => 'The Friendly Name' }
      @asset.friendly_name.should eq('The Friendly Name')
    end
  end

  describe '.url_for' do
    before(:each) do
      @asset = FactoryGirl.create(:uploaded_asset)
    end

    context 'when a non-existent asset is specified' do
      it 'returns an empty string' do
        UploadedAsset.url_for('not_an_asset_id').should eq('')
      end
    end

    context 'when an extant asset is specified' do
      it 'returns a URL' do
        url = UploadedAsset.url_for(@asset.name)
        url.should start_with('/system/')
        url.should include('.rb?')
      end
    end
  end

end
