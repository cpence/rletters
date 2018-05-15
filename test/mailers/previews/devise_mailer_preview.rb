# frozen_string_literal: true

# Preview the output from the DeviseMailer
class DeviseMailerPreview < ActionMailer::Preview
  # Preview the reset password instructions e-mail
  #
  # @return [void]
  def reset_password_instructions
    DeviseMailer.reset_password_instructions(User.first, 'asdftoken123')
  end

  # Preview the password changed e-mail
  #
  # @return [void]
  def password_change
    DeviseMailer.password_change(User.first)
  end
end
