
# Preview the output from the UserMailer
class UserMailerPreview < ActionMailer::Preview
  # Preview the job finished e-mail
  #
  # @return [void]
  def job_finished
    user = User.first || FactoryGirl.build_stubbed(:user)
    dataset = Dataset.where(user_id: user.to_param).first ||
              FactoryGirl.build_stubbed(:full_dataset, user: user)
    task = dataset.tasks.first ||
           FactoryGirl.build_stubbed(:task, dataset: dataset,
                                            job_type: 'ExportCitationsJob')

    UserMailer.job_finished_email(user.email, task)
  end
end
