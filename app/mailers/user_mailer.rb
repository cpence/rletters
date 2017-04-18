
# Send notification e-mails to users
#
# This mailer is responsible for sending e-mails to users when their analysis
# tasks complete.
class UserMailer < ApplicationMailer
  # E-mail users that their jobs have finished
  #
  # @param [String] email the address to send the mail
  # @param [Datasets::Task] task the task that just finished
  # @return [void]
  def job_finished_email(email, task)
    # Only way to get locals into the mail templates is to set instance vars
    @task = task

    mail(from: ENV['APP_EMAIL'], to: email,
         subject: I18n.t('user_mailer.job_finished.subject'))
  end
end
