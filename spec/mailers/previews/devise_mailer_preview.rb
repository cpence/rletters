# -*- encoding : utf-8 -*-

# Preview the output from the DeviseMailer
class DeviseMailerPreview < ActionMailer::Preview
  # Preview the reset password instructions e-mail
  #
  # @api private
  def reset_password_instructions
    user = User.first || FactoryGirl.build(:user)

    DeviseMailer.reset_password_instructions(user, 'asdftoken123')
  end
end
