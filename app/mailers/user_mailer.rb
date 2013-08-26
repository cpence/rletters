# -*- encoding : utf-8 -*-

# Send notification e-mails to users
#
# This mailer is responsible for sending e-mails to users when their analysis
# tasks complete.
class UserMailer < ActionMailer::Base
  default from: 'noreply@example.com'

  def job_finished_email(user, task)
    @user = user
    @task = task

    mail(from: Setting.app_email,
         to: @user.email,
         task: @task,
         subject: "#{Setting.app_name} analysis job completed")
  end
end
