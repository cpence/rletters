# frozen_string_literal: true

# Preview the output from the UserMailer
class UserMailerPreview < ActionMailer::Preview
  # Preview the job finished e-mail
  #
  # @return [void]
  def job_finished
    user = FactoryBot.build_stubbed(:user)
    dataset = FactoryBot.build_stubbed(:full_dataset, user: user)
    task = FactoryBot.build_stubbed(:task, dataset: dataset,
                                           job_type: 'ExportCitationsJob')

    UserMailer.job_finished_email(user.email, task)
  end
end
