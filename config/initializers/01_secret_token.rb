if Rails.env.development? || Rails.env.test?
  # Load some (obviously insecure) development/test tokens
  Rails.application.config.secret_token = 'x' * 30
  Rails.application.config.secret_key_base = 'x' * 30
else
  # Load from .env, raising an exception if not found
  unless ENV['SECRET_TOKEN']
    fail RuntimeError, "No secret tokens available in ENV. Please copy .env.example to .env, and run rake secrets:regen."
  end

  Rails.application.config.secret_token = ENV.fetch('SECRET_TOKEN')
  Rails.application.config.secret_key_base = ENV.fetch('SECRET_KEY_BASE')
end
