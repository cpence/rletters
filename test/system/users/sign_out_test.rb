# frozen_string_literal: true

require 'application_system_test_case'

class SignOutTest < ApplicationSystemTestCase
  test 'sign out when logged in' do
    sign_in_with
    sign_out

    assert_text 'Signed out successfully.'

    visit '/'
    assert_text 'Sign In'
    assert_no_text 'Sign Out'
  end
end
