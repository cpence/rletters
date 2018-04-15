require 'test_helper'

class Admin::UploadedAssetTest < ActiveSupport::TestCase
  test 'should be invalid with no name' do
    asset = build_stubbed(:uploaded_asset, name: nil)

    refute asset.valid?
  end

  test 'should be valid with name' do
    asset = build_stubbed(:uploaded_asset)

    assert asset.valid?
  end

  test 'should return translated friendly_name' do
    # There's no way to *delete* a translation from the I18n backend, so
    # we have to do this in one test to make sure they're in order
    asset = build_stubbed(:uploaded_asset)

    assert_equal asset.name, asset.friendly_name

    I18n.backend.store_translations :en, uploaded_assets:
      { asset.name.to_sym => 'The Friendly Name' }
    assert_equal 'The Friendly Name', asset.friendly_name
  end

  test 'should return empty url_for unknown asset' do
    assert_equal '', Admin::UploadedAsset.url_for('not_an_asset_id')
  end

  test 'should return correct url_for' do
    asset = create(:uploaded_asset)
    url = Admin::UploadedAsset.url_for(asset.name)

    assert url.start_with?('/static/image/')
    assert_includes url, (asset.to_param + '?')
  end
end
