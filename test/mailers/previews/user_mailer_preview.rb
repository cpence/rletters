
# Preview the output from the UserMailer
class UserMailerPreview < ActionMailer::Preview
  # Preview the job finished e-mail
  #
  # @return [void]
  def job_finished
    user = FactoryGirl.build_stubbed(:user)
    dataset = FactoryGirl.build_stubbed(:full_dataset, user: user)
    task = FactoryGirl.build_stubbed(:task, dataset: dataset,
                                            job_type: 'ExportCitationsJob')

    UserMailer.job_finished_email(user.email, task)
  end
end
