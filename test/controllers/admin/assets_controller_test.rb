require 'test_helper'

class Admin::AssetsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    post admin_login_url(password: ENV['ADMIN_PASSWORD'])
    get assets_url

    assert_response :success
  end

  test 'should not get index if not logged in' do
    get assets_url

    assert_redirected_to admin_login_url
  end

  test 'should post upload' do
    asset = Admin::Asset.first

    post admin_login_url(password: ENV['ADMIN_PASSWORD'])
    post upload_asset_url(asset),
         params: { file: fixture_file_upload(Rails.root.join('test', 'factories', '1x1.png')) }

    assert_redirected_to assets_url
    assert_equal '1x1.png', asset.reload.file.filename.to_s
  end

  test 'should not post upload without file' do
    post admin_login_url(password: ENV['ADMIN_PASSWORD'])
    post upload_asset_url(id: Admin::Asset.first.to_param)

    assert_response 400
  end

  test 'should not post upload for invalid asset' do
    post admin_login_url(password: ENV['ADMIN_PASSWORD'])
    post upload_asset_url(id: '99999'),
         params: { file: fixture_file_upload(Rails.root.join('test', 'factories', '1x1.png')) }

    assert_response 404
  end

  test 'should not be able to post upload if not logged in' do
    post upload_asset_url(id: Admin::Asset.first.to_param),
         params: { file: fixture_file_upload(Rails.root.join('test', 'factories', '1x1.png')) }

    assert_redirected_to admin_login_url
  end
end
