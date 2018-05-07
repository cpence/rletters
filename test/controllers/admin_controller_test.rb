# frozen_string_literal: true

require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    post admin_login_url(password: ENV['ADMIN_PASSWORD'])
    get admin_url

    assert_response :success
  end

  test 'should get login' do
    get admin_login_url

    assert_response :success
  end

  test 'should successfully log in' do
    post admin_login_url(password: ENV['ADMIN_PASSWORD'])

    assert_redirected_to admin_url
  end

  test 'should log out after logging in' do
    post admin_login_url(password: ENV['ADMIN_PASSWORD'])
    assert_redirected_to admin_url

    delete admin_logout_url
    assert_redirected_to admin_login_url

    get admin_url
    assert_redirected_to admin_login_url
  end

  test 'should redirect index if not logged in' do
    get admin_url

    assert_redirected_to admin_login_url
  end

  test 'should redirect logout if not logged in' do
    delete admin_logout_url

    assert_redirected_to admin_login_url
  end
end
