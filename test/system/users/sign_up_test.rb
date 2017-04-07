require 'application_system_test_case'

class SignUpTest < ApplicationSystemTestCase
  test 'sign up with valid data' do
    sign_up_with

    assert_text 'You have signed up successfully.'
  end

  test 'sign up with invalid e-mail' do
    sign_up_with(email: 'notanemail')

    assert_selector '.user_email.has-error'
  end

  test 'sign up with mismatched password' do
    sign_up_with(password_confirmation: 'changeme123')

    assert_selector '.user_password_confirmation.has-error .help-block',
                    text: "doesn't match Password"
  end
end
