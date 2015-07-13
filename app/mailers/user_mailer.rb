
# Send notification e-mails to users
#
# This mailer is responsible for sending e-mails to users when their analysis
# tasks complete.
class UserMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default from: 'noreply@example.com'

  layout 'ink_email'

  # E-mail users that their jobs have finished
  #
  # @param [String] email the address to send the mail
  # @param [String] task_id the ID of the task that just finished
  # @return [void]
  def job_finished_email(email, task_id)
    @task = Datasets::Task.find(task_id)

    mail(from: Admin::Setting.app_email,
         to: email,
         task: @task,
         subject: I18n.t('user_mailer.job_finished.subject',
                         app_name: Admin::Setting.app_name))
  end
end
