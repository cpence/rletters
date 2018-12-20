# frozen_string_literal: true

# A customized failure class for Devise
#
# This class ensures that when we fail to authenticate a user, we redirect
# back to the root page, rather than to the login page (since we no longer
# have a dedicated login action).
#
# This class is tested in the ApplicationControllerTest.
class DeviseFailure < Devise::FailureApp
  # The redirection URL on failure
  #
  # @return [String] the URL for redirection
  def redirect_url
    root_url
  end

  # Redirect on all failures
  #
  # This does not include support for HTTP basic authentication, which is fine,
  # because we don't want that.
  #
  # @return [void]
  def respond
    redirect
  end
end

# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  config.secret_key = if Rails.env.development? || Rails.env.test?
                        'x' * 30
                      else
                        ENV.fetch('DEVISE_SECRET_KEY')
                      end

  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class with
  # default "from" parameter.
  config.mailer_sender = "noreply@#{ENV['MAIL_DOMAIN'] || 'example.com'}"

  # Configure the class responsible to send e-mails.
  config.mailer = 'DeviseMailer'

  # Configure the parent class responsible to send e-mails.
  # config.parent_mailer = 'ActionMailer::Base'

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'devise/orm/active_record'

  # ==> Configuration for any authentication mechanism
  # Configure which keys are used when authenticating a user. The default is
  # just :email. You can configure it to use [:username, :subdomain], so for
  # authenticating a user, both parameters are required. Remember that those
  # parameters are used only when authenticating and not when retrieving from
  # session. If you need permissions, you should implement that in a before
  # filter. You can also supply a hash where the value is a boolean determining
  # whether or not authentication should be aborted when the value is not
  # present.
  # config.authentication_keys = [:email]

  # Configure parameters from the request object used for authentication. Each
  # entry given should be a request method and it will automatically be passed
  # to the find_for_authentication method and considered in your model lookup.
  # For instance, if you set :request_keys to [:subdomain], :subdomain will be
  # used on authentication. The same considerations mentioned for
  # authentication_keys also apply to request_keys.
  # config.request_keys = []

  # Configure which authentication keys should be case-insensitive.
  # These keys will be downcased upon creating or modifying a user and when
  # used to authenticate or find a user. Default is :email.
  config.case_insensitive_keys = [:email]

  # Configure which authentication keys should have whitespace stripped.
  # These keys will have whitespace before and after removed upon creating or
  # modifying a user and when used to authenticate or find a user. Default is
  # :email.
  config.strip_whitespace_keys = [:email]

  # Tell if authentication through request.params is enabled. True by default.
  # It can be set to an array that will enable params authentication only for
  # the given strategies, for example, `config.params_authenticatable =
  # [:database]` will enable it only for database (email + password)
  # authentication.
  # config.params_authenticatable = true

  # Tell if authentication through HTTP Auth is enabled. False by default.
  # It can be set to an array that will enable http authentication only for the
  # given strategies, for example, `config.http_authenticatable = [:database]`
  # will enable it only for database authentication. The supported strategies
  # are:
  # :database      = Support basic authentication with authentication key +
  #                  password
  # config.http_authenticatable = false

  # If 401 status code should be returned for AJAX requests. True by default.
  # config.http_authenticatable_on_xhr = true

  # The realm used in Http Basic Authentication. 'Application' by default.
  # config.http_authentication_realm = 'Application'

  # It will change confirmation, password recovery and other workflows
  # to behave the same regardless if the e-mail provided was right or wrong.
  # Does not affect registerable.
  # config.paranoid = true

  # By default Devise will store the user in session. You can skip storage for
  # :http_auth and :token_auth by adding those symbols to the array below.
  # Notice that if you are skipping storage for all authentication paths, you
  # may want to disable generating routes to Devise's sessions controller by
  # passing :skip => :sessions to `devise_for` in your config/routes.rb
  config.skip_session_storage = [:http_auth]

  # By default, Devise cleans up the CSRF token on authentication to
  # avoid CSRF token fixation attacks. This means that, when using AJAX
  # requests for sign in and sign up, you need to get a new CSRF token
  # from the server. You can disable this option at your own risk.
  # config.clean_up_csrf_token_on_authentication = true

  # When false, Devise will not attempt to reload routes on eager load.
  # This can reduce the time taken to boot the app but if your application
  # requires the Devise mappings to be loaded during boot time the application
  # won't boot properly.
  # config.reload_routes = true

  # ==> Configuration for :database_authenticatable
  # For bcrypt, this is the cost for hashing the password and defaults to 10.
  # If using other encryptors, it sets how many times you want the password
  # re-encrypted.
  #
  # Limiting the stretches to just one in testing will increase the performance
  # of your test suite dramatically. However, it is STRONGLY RECOMMENDED to not
  # use a value less than 10 in other environments. Note that, for bcrypt (the
  # default encryptor), the cost increases exponentially with the number of
  # stretches (e.g. a value of 20 is already extremely slow: approx. 60 seconds
  # for 1 calculation).
  config.stretches = Rails.env.test? ? 1 : 11

  # Set up a pepper to generate the hashed password.
  # config.pepper = '<%= SecureRandom.hex(64) %>'

  # Send a notification to the original email when the user's email is changed.
  # config.send_email_changed_notification = false

  # Send a notification email when the user's password is changed
  config.send_password_change_notification = true

  # ==> Configuration for :rememberable
  # The time the user will be remembered without asking for credentials again.
  config.remember_for = 2.weeks

  # Invalidates all the remember me tokens when the user signs out.
  config.expire_all_remember_me_on_sign_out = true

  # If true, extends the user's remember period when remembered via cookie.
  # config.extend_remember_period = false

  # Options to be passed to the created cookie. For instance, you can set
  # secure: true in order to force SSL only cookies.
  # config.rememberable_options = {}

  # ==> Configuration for :validatable
  # Range for password length.
  config.password_length = 8..72

  # Email regex used to validate email formats. It simply asserts that
  # one (and only one) @ exists in the given string. This is mainly
  # to give user feedback and not to assert the e-mail validity.
  # config.email_regexp = /\A[^@]+@[^@]+\z/

  # ==> Configuration for :recoverable
  #
  # Defines which key will be used when recovering the password for an account
  # config.reset_password_keys = [:email]

  # Time interval you can reset your password with a reset password key.
  # Don't put a too small interval or your users won't have the time to
  # change their passwords.
  config.reset_password_within = 6.hours

  # When set to false, does not sign a user in automatically after their password is
  # reset. Defaults to true, so a user is signed in automatically after a reset.
  config.sign_in_after_reset_password = true

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check
  # for "users/sessions/new". It's turned off by default because it's slower if
  # you are using only default views.
  # config.scoped_views = false

  # Configure the default scope given to Warden. By default it's the first
  # devise role declared in your routes (usually :user).
  # config.default_scope = :user

  # Set this configuration to false if you want /users/sign_out to sign out
  # only the current scope. By default, Devise signs out all scopes.
  # config.sign_out_all_scopes = true

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html, should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  #
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists.
  #
  # The "*/*" below is required to match Internet Explorer requests.
  # config.navigational_formats = ["*/*", :html]

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = Rails.env.test? ? :get : :delete

  # ==> Warden configuration
  # If you want to use other strategies, that are not supported by Devise, or
  # change the failure app, you can configure them inside the config.warden block.
  config.warden do |manager|
    # Redirect to the root on a failed sign-in
    manager.failure_app = DeviseFailure
  end
end
