
# The environment variables that should be shown on the administration
# dashboard
ENVIRONMENT_VARIABLES_TO_PRINT = {
  'admin.index.branding_vars':
    ['APP_NAME', 'APP_EMAIL', 'GOOGLE_ANALYTICS_KEY'],
  'admin.index.server_vars':
    ['HTTPS_ONLY', 'VERBOSE_LOGS', 'BLOCKING_JOBS', 'DATABASE_URL', 'SOLR_URL',
     'SOLR_TIMEOUT', 'FILE_PATH', 'S3_ACCESS_KEY_ID', 'S3_BUCKET',
     'S3_REGION'],
  'admin.index.mail_vars':
    ['MAIL_DOMAIN', 'MAIL_DELIVERY_METHOD', 'MAILGUN_API_KEY',
     'MANDRILL_API_KEY', 'POSTMARK_API_KEY', 'SENDGRID_API_USER',
     'SENDGRID_API_KEY', 'SENDMAIL_LOCATION', 'SENDMAIL_ARGUMENTS',
     'SMTP_ADDRESS', 'SMTP_PORT', 'SMTP_DOMAIN', 'SMTP_USERNAME',
     'SMTP_AUTHENTICATION', 'SMTP_ENABLE_STARTTLS_AUTO',
     'SMTP_OPENSSL_VERIFY_MODE', 'MAILER_PREVIEWS'],
  'admin.index.feature_flags':
    ['MAINTENANCE_MESSAGE', 'NLP_TOOL_PATH'],
  'admin.index.ruby_vars':
    ['RBENV_VERSION', 'RUBYOPT', 'RUBYLIB', 'GEM_PATH', 'GEM_HOME',
     'BUNDLE_BIN_PATH', 'BUNDLE_GEMFILE', 'RACK_ENV', 'RAILS_ENV']
}.freeze

# The administrative backend for RLetters
#
# This controller handles display of the administration pages, which allow
# the site administrator to configure and modify a variety of settings and
# data.
class AdminController < ApplicationController
  before_action :authenticate_administrator!
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
end
