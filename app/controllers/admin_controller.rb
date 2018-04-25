require 'digest'

# The environment variables that should be shown on the administration
# dashboard
ENVIRONMENT_VARIABLES_TO_PRINT = {
  'admin.index.branding_vars':
    ['APP_NAME', 'APP_EMAIL'],
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
  before_action :require_login, except: :login
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
    params.permit(:password)
    if params[:password]
      password_digest = Digest::SHA256.hexdigest(params[:password])
      admin_pw_digest = Digest::SHA256.hexdigest(ENV['ADMIN_PASSWORD'])

      if password_digest == admin_pw_digest
        session[:admin_password] = password_digest
        redirect_to admin_path
      else
        flash[:alert] = I18n.t('admin.login_error')
      end
    end
  end

  # Remove the administrator password from the session
  #
  # @return [void]
  def logout
    session.delete(:admin_password)
    redirect_to admin_login_path
  end

  # Show an editable list of all categories
  #
  # @return [void]
  def categories_index
  end

  # Update the order of the categories
  #
  # This is called by the Nestable JS code whenever the user drags around the
  # order of the categories.
  #
  # @return [void]
  def categories_order
    # This will already have been deserialized by Rails, and is thus likely to
    # be an array (though maybe a Hash if there's only one of them).
    new_order = params[:order]
    new_order = [new_order] if new_order.is_a?(Hash)

    # Loop the roots and make them roots, then recursively set their children
    new_order.each do |h|
      id = h['id']
      category = Documents::Category.find(id)
      category.parent = nil
      category.save

      set_children_for(category, h)
    end

    head :no_content
  end

  private

  # Ensure that the administrator is authenticated, and redirect to the login
  # page if not
  #
  # @return [void]
  def require_login
    admin_pw_digest = Digest::SHA256.hexdigest(ENV['ADMIN_PASSWORD'])
    if session[:admin_password] != admin_pw_digest
      session.delete(:admin_password)
      redirect_to admin_login_path, alert: I18n.t('admin.login_error')
    end
  end

  # Take the given hash and category, and set its children as appropriate
  #
  # @return [void]
  def set_children_for(category, h)
    if h['children']
      h['children'].each do |ch|
        child = Documents::Category.find(ch['id'])
        child.parent = category
        child.save

        set_children_for(child, ch)
      end
    else
      # Can't remove children, so nil out the parent of anything that's listed
      # as a child of this node
      category.children.each do |c|
        c.parent = nil
        c.save
      end
    end
  end
end
