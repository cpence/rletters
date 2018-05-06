# frozen_string_literal: true
require 'application_system_test_case'

class SignInTest < ApplicationSystemTestCase
  test 'sign in without an account' do
    sign_in_with({}, false)

    assert_text(/Invalid [Ee]-?mail( address)? or password./)
    assert_text 'Sign In'
    assert_no_text 'Sign Out'
  end

  test 'sign in with an account' do
    sign_in_with

    assert_text 'Signed in successfully.'

    visit '/'
    assert_text 'Sign Out'
    assert_no_text 'Sign In'
  end
end
