# frozen_string_literal: true

# Preview the output from the DeviseMailer
class DeviseMailerPreview < ActionMailer::Preview
  # Preview the reset password instructions e-mail
  #
  # @return [void]
  def reset_password_instructions
    user = FactoryBot.build_stubbed(:user)

    DeviseMailer.reset_password_instructions(user, 'asdftoken123')
  end

  # Preview the password changed e-mail
  #
  # @return [void]
  def password_change
    user = FactoryBot.build_stubbed(:user)

    DeviseMailer.password_change(user)
  end
end
