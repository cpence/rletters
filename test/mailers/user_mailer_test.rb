require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test 'reset_password_instructions' do
    task = build_stubbed(:task)
    email = UserMailer.job_finished_email(task.dataset.user.email, task)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [task.dataset.user.email], email.to
    assert_equal [ENV['APP_EMAIL']], email.from
    assert_equal 'Analysis job complete', email.subject

    assert_includes email.text_part.body.to_s, task.name
    assert_includes email.text_part.body.to_s, task.dataset.name
    assert_includes email.text_part.body.to_s, Rails.application.routes.url_helpers.workflow_fetch_url(host: ENV['MAIL_DOMAIN'])
  end
end
