# frozen_string_literal: true

require 'test_helper'

module Admin
  class AssetTest < ActiveSupport::TestCase
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
  end
end
