# frozen_string_literal: true

require 'digest'

# The environment variables that should be shown on the administration
# dashboard
ENVIRONMENT_VARIABLES_TO_PRINT = {
  '.branding_vars':
    %w[APP_NAME APP_EMAIL],
  '.server_vars':
    %w[HTTPS_ONLY VERBOSE_LOGS BLOCKING_JOBS DATABASE_URL SOLR_URL
       SOLR_TIMEOUT FILE_PATH S3_ACCESS_KEY_ID S3_BUCKET S3_REGION],
  '.mail_vars':
    %w[MAIL_DOMAIN MAIL_DELIVERY_METHOD MAILGUN_API_KEY MANDRILL_API_KEY
       POSTMARK_API_KEY SENDGRID_API_USER SENDGRID_API_KEY SENDMAIL_LOCATION
       SENDMAIL_ARGUMENTS SMTP_ADDRESS SMTP_PORT SMTP_DOMAIN SMTP_USERNAME
       SMTP_AUTHENTICATION SMTP_ENABLE_STARTTLS_AUTO SMTP_OPENSSL_VERIFY_MODE
       MAILER_PREVIEWS],
  '.feature_flags':
    %w[MAINTENANCE_MESSAGE ARTICLE_DATES_JOB_DISABLED COLLOCATION_JOB_DISABLED
       COOCCURRENCE_JOB_DISABLED CRAIG_ZETA_JOB_DISABLED
       EXPORT_CITATIONS_JOB_DISABLED NAMED_ENTITIES_JOB_DISABLED
       NETWORK_JOB_DISABLED TERM_DATES_JOB_DISABLED
       WORD_FREQUENCY_JOB_DISABLED],
  '.ruby_vars':
    %w[RBENV_VERSION RUBYOPT RUBYLIB GEM_PATH GEM_HOME BUNDLE_BIN_PATH
       BUNDLE_GEMFILE RACK_ENV RAILS_ENV]
}.freeze

# The administrative backend for RLetters
#
# This controller handles display of the administration pages, which allow
# the site administrator to configure and modify a variety of settings and
# data.
class AdminController < ApplicationController
  before_action :authenticate_admin!, except: :login
  layout 'admin'

  # Show the administration dashboard
  #
  # @return [void]
  def index
    @config_vars = ENVIRONMENT_VARIABLES_TO_PRINT
    @corpus_size = RLetters::Solr::CorpusStats.new.size
    @ping = RLetters::Solr::Connection.ping
    @solr_info = RLetters::Solr::Connection.info
  end

  # Log in to the administration system
  #
  # @return [void]
  def login
    return unless params[:password]

    password_digest = Digest::SHA256.hexdigest(params[:password])
    admin_pw_digest = Digest::SHA256.hexdigest(ENV['ADMIN_PASSWORD'])

    if password_digest == admin_pw_digest
      session[:admin_password] = password_digest
      redirect_to admin_path
    else
      flash[:alert] = I18n.t('admin.login_error')
    end
  end

  # Remove the administrator password from the session
  #
  # @return [void]
  def logout
    session.delete(:admin_password)
    redirect_to admin_login_path
  end
end
