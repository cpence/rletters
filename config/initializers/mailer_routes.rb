
# Set mailer defaults
Rails.application.config.action_mailer.default_url_options =
  { host: ENV['APP_MAIL_DOMAIN'] }
ActionMailer::Base.default_url_options =
  { host: ENV['APP_MAIL_DOMAIN'] }
