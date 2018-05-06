# frozen_string_literal: true

module Users
  # Modify behavior of the Devise password-reset system.
  class PasswordsController < Devise::PasswordsController
    protected

    # Redirect to root after sending the reset password email
    #
    # This method is called by Devise.
    #
    # @return [void]
    def after_sending_reset_password_instructions_path_for(_resource)
      root_url
    end

    # Redirect to root after successfully resetting password
    #
    # This method is called by Devise.
    #
    # @return [void]
    def after_resetting_password_path_for(_resource)
      root_url
    end
  end
end
