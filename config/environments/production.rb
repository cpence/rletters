# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Enable caching.
  config.action_controller.perform_caching = true

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to
  # raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Specifies the header that your server uses for sending files. Default to
  # nginx.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force SSL if requested
  config.force_ssl = (ENV['HTTPS_ONLY'] || 'false').to_boolean
  config.ssl_options = {
    hsts: {
      subdomains: true
    }
  }

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

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
  config.action_mailer.smtp_settings ||= {}
  config.action_mailer.smtp_settings.merge!({
    address: ENV['SMTP_ADDRESS'] || 'localhost',
    port: ENV['SMTP_PORT']&.to_i || 25,
    domain: ENV['SMTP_DOMAIN'] || nil,
    user_name: ENV['SMTP_USERNAME'] || nil,
    password: ENV['SMTP_PASSWORD'] || nil,
    authentication: ENV['SMTP_AUTHENTICATION']&.to_sym || nil,
    enable_starttls_auto: ENV['SMTP_ENABLE_STARTTLS_AUTO'].nil? ? nil :
                          ENV['SMTP_ENABLE_STARTTLS_AUTO'].to_boolean,
    openssl_verify_mode: ENV['SMTP_OPENSSL_VERIFY_MODE'] || nil
  }.compact)

  config.action_mailer.sendmail_settings ||= {}
  config.action_mailer.sendmail_settings.merge!(
    location: ENV['SENDMAIL_LOCATION'] || '/usr/sbin/sendmail',
    arguments: ENV['SENDMAIL_ARGUMENTS'] || '-i -t'
  )

  # Set the delivery method
  GOOD_DELIVERY_METHODS = %i[mailgun mandrill postmark sendgrid sendmail
                             smtp].freeze

  delivery_method = (ENV['MAIL_DELIVERY_METHOD'] || 'sendmail').to_sym
  unless GOOD_DELIVERY_METHODS.include?(delivery_method)
    raise <<-ERROR.strip_heredoc
      The mail delivery method configured in ENV is invalid. Please edit .env
      and set to one of the delivery methods present in
      config/initializers/mail.rb.
    ERROR
  end

  config.action_mailer.delivery_method = delivery_method
end
