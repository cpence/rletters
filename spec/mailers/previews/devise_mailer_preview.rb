
# Preview the output from the DeviseMailer
class DeviseMailerPreview < ActionMailer::Preview
  # Preview the reset password instructions e-mail
  #
  # @return [void]
  def reset_password_instructions
    user = User.first || FactoryGirl.build_stubbed(:user)

    DeviseMailer.reset_password_instructions(user, 'asdftoken123')
  end
end
