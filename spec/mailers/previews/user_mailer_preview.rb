# -*- encoding : utf-8 -*-

# Preview the output from the UserMailer
class UserMailerPreview < ActionMailer::Preview
  # Preview the job finished e-mail
  #
  # @api private
  def job_finished
    user = User.first || FactoryGirl.build(:user)
    dataset = Dataset.where(user_id: user.to_param).first ||
              FactoryGirl.build(:full_dataset, user: user)
    task = dataset.analysis_tasks.first ||
           FactoryGirl.build(:analysis_task, dataset: dataset,
                                             job_type: 'ExportCitations')

    UserMailer.job_finished_email(user.email, task.to_param)
  end
end
