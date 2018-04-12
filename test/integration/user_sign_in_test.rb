require 'test_helper'

class UserSignInTest < ActionDispatch::IntegrationTest
  test 'should redirect user sign in to root' do
    user = create(:user)

    post user_session_url(user: { email: user.email,
                                  password: user.password,
                                  password_confirmation: user.password })

    assert_redirected_to root_url
    refute_nil flash[:notice]
    assert_nil flash[:alert]
  end

  test 'should redirect user sign out to root' do
    user = create(:user)

    post user_session_url(user: { email: user.email,
                                  password: user.password,
                                  password_confirmation: user.password })
    get destroy_user_session_url

    assert_redirected_to root_url
    refute_nil flash[:notice]
    assert_nil flash[:alert]
  end
end
