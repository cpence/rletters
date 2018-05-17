# frozen_string_literal: true

require 'test_helper'

module Users
  class PasswordsControllerTest < ActionDispatch::IntegrationTest
    test 'should redirect to root after reset password mail' do
      user = create(:user)
      post user_password_path, params: { user: { email: user.email } }

      assert_redirected_to root_path
    end
  end
end
