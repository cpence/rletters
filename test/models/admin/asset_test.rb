# frozen_string_literal: true

require 'test_helper'

module Admin
  class AssetTest < ActiveSupport::TestCase
    include ActionDispatch::TestProcess

    test 'should be invalid with no name' do
      asset = build_stubbed(:asset, name: nil)

      refute asset.valid?
    end

    test 'should be valid with name' do
      asset = build_stubbed(:asset)

      assert asset.valid?
    end

    test 'should return translated friendly_name' do
      # There's no way to *delete* a translation from the I18n backend, so
      # we have to do this in one test to make sure they're in order
      asset = build_stubbed(:asset)

      assert_equal asset.name, asset.friendly_name

      I18n.backend.store_translations :en, assets:
        { asset.name.to_sym => 'The Friendly Name' }
      assert_equal 'The Friendly Name', asset.friendly_name
    end

    test 'usable should fail for missing asset' do
      refute Admin::Asset.usable? 'favicon'
    end

    test 'usable should fail for asset present without file' do
      asset = create(:asset)

      refute Admin::Asset.usable? asset.name
    end

    test 'usable should work for good asset' do
      asset = create(:asset, name: 'favicon', file: fixture_file_upload(Rails.root.join('test', 'factories', '1x1.png')))

      assert Admin::Asset.usable? asset.name
    end
  end
end
