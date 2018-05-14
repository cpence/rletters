# frozen_string_literal: true

require 'digest'

# The environment variables that should be shown on the administration
# dashboard, with their default values
ENVIRONMENT_VARIABLES_TO_PRINT = {
  '.branding_vars': {
    APP_NAME: 'RLetters',
    APP_EMAIL: 'noreply@example.com'
  },
  '.server_vars': {
    WEB_CONCURRENCY: '2',
    RAILS_MAX_THREADS: '5',
    HTTPS_ONLY: 'false',
    RAILS_SERVE_STATIC_FILES: 'true',
    RAILS_LOG_TO_STDOUT: 'true',
    BLOCKING_JOBS: 'false',
    DATABASE_URL: '<unset>',
    SOLR_URL: '<unset>',
    SOLR_TIMEOUT: '120',
    FILE_PATH: '<unset>',
    S3_ACCESS_KEY_ID: '<unset>',
    S3_BUCKET: '<unset>',
    S3_REGION: '<unset>'
  },
  '.mail_vars': {
    MAIL_DOMAIN: 'example.com',
    MAIL_DELIVERY_METHOD: 'sendmail',
    MAILGUN_API_KEY: '<unset>',
    MANDRILL_API_KEY: '<unset>',
    POSTMARK_API_KEY: '<unset>',
    SENDGRID_API_USER: '<unset>',
    SENDGRID_API_KEY: '<unset>',
    SENDMAIL_LOCATION: '/usr/sbin/sendmail',
    SENDMAIL_ARGUMENTS: '-i -t',
    SMTP_ADDRESS: 'localhost',
    SMTP_PORT: '25',
    SMTP_DOMAIN: '<unset>',
    SMTP_USERNAME: '<unset>',
    SMTP_AUTHENTICATION: '<unset>',
    SMTP_ENABLE_STARTTLS_AUTO: '<unset>',
    SMTP_OPENSSL_VERIFY_MODE: '<unset>'
  },
  '.feature_flags': {
    MAINTENANCE_MESSAGE: '<unset>',
    ARTICLE_DATES_JOB_DISABLED: 'false',
    COLLOCATION_JOB_DISABLED: 'false',
    COOCCURRENCE_JOB_DISABLED: 'false',
    CRAIG_ZETA_JOB_DISABLED: 'false',
    EXPORT_CITATIONS_JOB_DISABLED: 'false',
    NAMED_ENTITIES_JOB_DISABLED: 'false',
    NETWORK_JOB_DISABLED: 'false',
    TERM_DATES_JOB_DISABLED: 'false',
    WORD_FREQUENCY_JOB_DISABLED: 'false'
  },
  '.ruby_vars': {
    RBENV_VERSION: '',
    RUBYOPT: '',
    RUBYLIB: '',
    GEM_PATH: '',
    GEM_HOME: '',
    BUNDLE_BIN_PATH: '',
    BUNDLE_GEMFILE: '',
    RACK_ENV: '',
    RAILS_ENV: ''
  }
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

    if ENV['ADMIN_PASSWORD'].blank?
      flash[:alert] = I18n.t('admin.login_unset')
      return
    end

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
