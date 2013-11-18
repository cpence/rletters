# -*- encoding : utf-8 -*-

# Send notification e-mails to users
#
# This mailer is responsible for sending e-mails to users when their analysis
# tasks complete.
class UserMailer < ActionMailer::Base
  include Resque::Mailer
  default from: 'noreply@example.com'

  def job_finished_email(email, task_id)
    @task = Datasets::AnalysisTask.find(task_id)

    mail(from: Admin::Setting.app_email,
         to: email,
         task: @task,
         subject: "#{Admin::Setting.app_name} analysis job completed")
  end
end
