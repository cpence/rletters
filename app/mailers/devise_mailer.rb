# frozen_string_literal: true

# Devise's user notification mailer
#
# We override this class in order to use our custom mail layout.
class DeviseMailer < ApplicationMailer
  include Devise::Mailers::Helpers

  def reset_password_instructions(record, token, opts={})
    @token = token
    initialize_from_record(record)

    make_bootstrap_mail headers_for(:reset_password_instructions, opts)
  end

  def password_change(record, opts={})
    initialize_from_record(record)

    make_bootstrap_mail headers_for(:password_change, opts)
  end
end
