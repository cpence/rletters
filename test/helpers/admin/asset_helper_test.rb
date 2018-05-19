# frozen_string_literal: true

require 'test_helper'

module Admin
  class AssetHelperTest < ActionView::TestCase
    test 'with_asset does not call block for missing asset' do
      with_asset 'nope' do
        flunk
      end
    end

    test 'with_asset does not call block for asset without file' do
      asset = create(:asset)

      with_asset asset.name do
        flunk
      end
    end

    test 'with_asset works' do
      create(
        :asset,
        name: 'favicon',
        file: fixture_file_upload(Rails.root.join('test', 'factories', '1x1.png'))
      )

      with_asset 'favicon' do |url|
        assert url.present?
      end
    end
  end
end
