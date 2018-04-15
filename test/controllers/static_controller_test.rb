require 'test_helper'

class StaticControllerTest < ActionDispatch::IntegrationTest
  test 'should not get image with invalid id' do
    get static_image_url(id: '123456789')

    assert_response 404
  end

  test 'should get image' do
    asset = create(:uploaded_asset)

    get static_image_url(id: asset.to_param)

    assert_response :success
    assert_equal 'image/png', @response.content_type
    assert @response.body.length > 0
  end
end
