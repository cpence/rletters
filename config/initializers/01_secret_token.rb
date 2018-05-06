# frozen_string_literal: true

if Rails.env.development? || Rails.env.test?
  # Load some (obviously insecure) development/test tokens
  Rails.application.config.secret_key_base = 'x' * 30
else
  # Load from .env, raising an exception if not found
  unless ENV['SECRET_KEY_BASE']
    fail <<-ERROR.strip_heredoc
      No secret keys available in ENV. Please copy .env.example to .env, and
      run rake rletters:secrets:regen.
    ERROR
  end

  Rails.application.config.secret_key_base = ENV.fetch('SECRET_KEY_BASE')
end
