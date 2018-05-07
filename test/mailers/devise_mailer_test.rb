# frozen_string_literal: true

require 'test_helper'

class DeviseMailerTest < ActionMailer::TestCase
  test 'reset_password_instructions' do
    user = build_stubbed(:user, reset_password_token: 'resettoken')
    email = DeviseMailer.reset_password_instructions(user, 'resettoken')

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [user.email], email.to
    assert_equal [ENV['APP_EMAIL']], email.from
    assert_equal 'Reset password instructions', email.subject

    url = Rails.application.routes.url_helpers.edit_user_password_url(@user, reset_password_token: 'resettoken', host: ENV['MAIL_DOMAIN'])
    assert_includes email.text_part.body.to_s, url
    assert_includes email.text_part.body.to_s, user.name
  end

  test 'password_change' do
    user = build_stubbed(:user)
    email = DeviseMailer.password_change(user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [user.email], email.to
    assert_equal [ENV['APP_EMAIL']], email.from
    assert_equal 'Your password was changed', email.subject

    assert_includes email.text_part.body.to_s, user.name
  end
end
