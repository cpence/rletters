require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    sign_in create(:administrator)

    get admin_url

    assert_response :success
  end

  test 'should redirect index if not logged in' do
    get admin_url

    assert_redirected_to new_administrator_session_url
  end
end
