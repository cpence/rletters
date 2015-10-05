
# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  # The secret key used by Devise. Devise uses this key to generate
  # random tokens. Changing this key will render invalid all existing
  # confirmation, reset password and unlock tokens in the database.
  if Rails.env.development? || Rails.env.test?
    config.secret_key = 'x' * 30
  else
    config.secret_key = ENV.fetch['DEVISE_SECRET_KEY']
  end

  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class with
  # default "from" parameter.
  config.mailer_sender = "noreply@#{ENV['APP_MAIL_DOMAIN']}"

  # Configure the class responsible to send e-mails.
  config.mailer = 'DeviseMailer'

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'devise/orm/active_record'

  # Configure which authentication keys should be case-insensitive.
  # These keys will be downcased upon creating or modifying a user and when
  # used to authenticate or find a user. Default is :email.
  config.case_insensitive_keys = [:email]

  # Configure which authentication keys should have whitespace stripped.
  # These keys will have whitespace before and after removed upon creating or
  # modifying a user and when used to authenticate or find a user. Default is
  # :email.
  config.strip_whitespace_keys = [:email]

  # If http headers should be returned for AJAX requests. True by default.
  # This makes real trouble for jQuery Mobile, and causes us not to get the
  # redirect through from an unauthorized user to the login page.
  config.http_authenticatable_on_xhr = false

  # By default Devise will store the user in session. You can skip storage for
  # :http_auth and :token_auth by adding those symbols to the array below.
  # Notice that if you are skipping storage for all authentication paths, you
  # may want to disable generating routes to Devise's sessions controller by
  # passing :skip => :sessions to `devise_for` in your config/routes.rb
  config.skip_session_storage = [:http_auth]

  # ==> Configuration for :database_authenticatable
  # For bcrypt, this is the cost for hashing the password and defaults to 10.
  # If using other encryptors, it sets how many times you want the password
  # re-encrypted.
  #
  # Limiting the stretches to just one in testing will increase the performance
  # of your test suite dramatically. However, it is STRONGLY RECOMMENDED to not
  # use a value less than 10 in other environments.
  config.stretches = Rails.env.test? ? 1 : 10

  # ==> Configuration for :rememberable
  # The time the user will be remembered without asking for credentials again.
  config.remember_for = 2.weeks

  # If true, extends the user's remember period when remembered via cookie.
  # config.extend_remember_period = false

  # Options to be passed to the created cookie. For instance, you can set
  # secure: true in order to force SSL only cookies.
  # config.rememberable_options = {}

  # ==> Configuration for :validatable
  # Range for password length. Default is 6..128.
  config.password_length = 6..128

  # Email regex used to validate email formats. It simply asserts that
  # an one (and only one) @ exists in the given string. This is mainly
  # to give user feedback and not to assert the e-mail validity.
  config.email_regexp = /\A[^@]+@[^@]+\z/

  # ==> Configuration for :encryptable
  # Allow you to use another encryption algorithm besides bcrypt (default). You
  # can use :sha1, :sha512 or encryptors from others authentication tools as
  # :clearance_sha1, :authlogic_sha512 (then you should set stretches above to
  # 20 for default behavior) and :restful_authentication_sha1 (then you should
  # set stretches to 10, and copy REST_AUTH_SITE_KEY to pepper)
  # config.encryptor = :sha512

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check
  # for "users/sessions/new". It's turned off by default because it's slower if
  # you are using only default views.
  config.scoped_views = true

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

  # Redirect to the root on a failed sign-in
  config.warden do |manager|
    manager.failure_app = DeviseFailure
  end
end

# Use the 'full_page' layout for all Devise views
Rails.application.config.to_prepare do
  Devise::SessionsController.layout 'full_page'
  Devise::RegistrationsController.layout 'full_page'
  Devise::ConfirmationsController.layout 'full_page'
  Devise::UnlocksController.layout 'full_page'
  Devise::PasswordsController.layout 'full_page'
end
