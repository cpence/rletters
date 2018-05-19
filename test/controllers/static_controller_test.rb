# frozen_string_literal: true

require 'test_helper'

class StaticControllerTest < ActionDispatch::IntegrationTest
  test 'should get cookies' do
    get static_cookies_url

    assert_response :success
  end

  test 'should get user data' do
    get static_user_data_url

    assert_response :success
  end

  test 'should not get echo' do
    get static_echo_url

    assert_response :not_found
  end

  test 'should post echo and return what was posted' do
    post static_echo_url, params: {
      data: 'a string',
      content_type: 'text/plain',
      filename: 'test.txt'
    }

    assert_valid_download 'text/plain', @response
  end

  test 'should 404 without favicon' do
    get favicon_url(format: :ico)

    assert_response :not_found
  end

  test 'should redirect if favicon present' do
    create(
      :asset,
      name: 'favicon',
      file: fixture_file_upload(Rails.root.join('test', 'factories', '1x1.png'))
    )

    get favicon_url(format: :ico)

    assert_response :redirect
  end

  test 'should get manifest' do
    get manifest_url(format: :json)

    assert_response :success
  end

  test 'should get browserconfig' do
    get browserconfig_url(format: :xml)

    assert_response :success
  end
end
