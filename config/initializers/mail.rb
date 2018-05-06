# frozen_string_literal: true

# Mailer delivery options
if Rails.env.test?
  # Tell Action Mailer not to deliver emails to the real world
  Rails.application.config.action_mailer.delivery_method = :test
elsif Rails.env.development?
  # Save mails to file so that we can inspect them
  Rails.application.config.action_mailer.delivery_method = :file
  ActionMailer::Base.file_settings = { location: Rails.root.join('tmp/mail') }
else
  # Add delivery methods to ActionMailer from multi_mail
  ActionMailer::Base.add_delivery_method :mailgun, MultiMail::Sender::Mailgun,
                                         api_key: ENV['MAILGUN_API_KEY'],
                                         domain: ENV['MAIL_DOMAIN']
  ActionMailer::Base.add_delivery_method :mandrill,
                                         MultiMail::Sender::Mandrill,
                                         api_key: ENV['MANDRILL_API_KEY']
  ActionMailer::Base.add_delivery_method :postmark,
                                         MultiMail::Sender::Postmark,
                                         api_key: ENV['POSTMARK_API_KEY']
  ActionMailer::Base.add_delivery_method :sendgrid,
                                         MultiMail::Sender::SendGrid,
                                         api_user: ENV['SENDGRID_API_USER'],
                                         api_key: ENV['SENDGRID_API_KEY']

  # Get other configuration parameters from ENV
  Rails.application.config.action_mailer.smtp_settings ||= {}
  Rails.application.config.action_mailer.smtp_settings.merge!({
    address: ENV['SMTP_ADDRESS'] || 'localhost',
    port: ENV['SMTP_PORT']&.to_i || 25,
    domain: ENV['SMTP_DOMAIN'] || nil,
    user_name: ENV['SMTP_USERNAME'] || nil,
    password: ENV['SMTP_PASSWORD'] || nil,
    authentication: ENV['SMTP_AUTHENTICATION']&.to_sym || nil,
    enable_starttls_auto: (ENV['SMTP_ENABLE_STARTTLS_AUTO'] || nil) == 'true',
    openssl_verify_mode: ENV['SMTP_OPENSSL_VERIFY_MODE'] || nil
  }.compact)

  Rails.application.config.action_mailer.sendmail_settings ||= {}
  Rails.application.config.action_mailer.sendmail_settings.merge!({
    location: ENV['SENDMAIL_LOCATION'] || '/usr/sbin/sendmail',
    arguments: ENV['SENDMAIL_ARGUMENTS'] || '-i -t'
  })

  # Set the delivery method
  GOOD_DELIVERY_METHODS = [:mailgun, :mandrill, :postmark, :sendgrid,
                           :sendmail, :smtp]

  delivery_method = (ENV['MAIL_DELIVERY_METHOD'] || 'sendmail').to_sym
  unless GOOD_DELIVERY_METHODS.include?(delivery_method)
    raise <<-ERROR.strip_heredoc
      The mail delivery method configured in ENV is invalid. Please edit .env
      and set to one of the delivery methods present in
      config/initializers/mail.rb.
    ERROR
  end

  Rails.application.config.action_mailer.delivery_method = delivery_method
end

# Set mailer defaults
Rails.application.config.action_mailer.default_url_options =
  { host: ENV['MAIL_DOMAIN'] }
ActionMailer::Base.default_url_options =
  { host: ENV['MAIL_DOMAIN'] }

# Configure Inky, our mail template engine
Inky.configure do |config|
  config.template_engine = :haml
end
