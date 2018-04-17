require 'test_helper'

class UserControllerTest < ActionDispatch::IntegrationTest
  test 'should redirect export when not logged in' do
    get user_export_url

    assert_redirected_to root_url
  end

  test 'should 404 export when logged in w/o export' do
    sign_in create(:user)

    get user_export_url

    assert_response 404
  end

  test 'should download export when logged in with export' do
    user = create(:user)

    ios = StringIO.new('not really a zip but whatever')
    file = Paperclip.io_adapters.for(ios)
    file.original_filename = 'export.zip'
    file.content_type = 'application/zip'

    user.export_archive = file
    user.save

    sign_in user

    get user_export_url

    assert_response :success
    assert_equal 'application/zip', @response.content_type
    assert @response.body.length > 0
  end
end
