# frozen_string_literal: true

# The main application controller for RLetters
#
# This controller implements functionality shared throughout the entire
# RLetters site.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout :layout_for

  # Render the full_page layout on Devise views
  #
  # @return [String] the layout to render
  def layout_for
    if devise_controller?
      'full_page'
    else
      'application'
    end
  end

  private

  before_action :set_locale, :set_timezone, :set_sentry_params

  # Set the locale if the user is logged in
  #
  # This function is called as a `before_action` in all controllers, you do
  # not need to call it yourself.  Do not disable it, or the locale system
  # will go haywire.
  #
  # @return [void]
  def set_locale
    I18n.locale = if user_signed_in?
                    current_user.language.to_sym
                  else
                    I18n.default_locale
                  end
  end

  # Set the timezone if the user is logged in
  #
  # This function is called as a `before_action` in all controllers, you do
  # not need to call it yourself.  Do not disable it, or the timezone system
  # will go haywire.
  #
  # @return [void]
  def set_timezone
    Time.zone = if user_signed_in?
                  current_user.timezone
                else
                  'Eastern Time (US & Canada)'
                end
  end

  # Pass extra context variables to Sentry
  #
  # This function is called as a `before_action` in all controllers, you do
  # not need to call it yourself.
  #
  # @return [void]
  def set_sentry_params
    return unless ENV['SENTRY_DSN'].present?

    Raven.user_context(id: current_user.email) if user_signed_in?
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  protected

  # Redirect to the root on successful sign in
  #
  # This method is called by Devise.
  #
  # @param [User] resource the user that just signed in
  # @return [void]
  def after_sign_in_path_for(_resource)
    root_url
  end

  # Redirect to the root on successful sign out
  #
  # This method is called by Devise.
  #
  # @return [void]
  def after_sign_out_path_for(_resource)
    root_url
  end

  # Ensure that the administrator is authenticated, and redirect to the login
  # page if not
  #
  # @return [void]
  def authenticate_admin!
    if ENV['ADMIN_PASSWORD'].present?
      admin_pw_digest = Digest::SHA256.hexdigest(ENV['ADMIN_PASSWORD'])
      return if session[:admin_password] == admin_pw_digest

      alert = I18n.t('admin.login_error')
    else
      alert = I18n.t('admin.login_unset')
    end

    session.delete(:admin_password)
    redirect_to admin_login_path, alert: alert
  end

  # Set cache control headers
  #
  # This helper can be called when we want a page to expire.  This is similar
  # to Rails' `expires_now` function, but sets more headers to work with more
  # browsers.
  #
  # @return [void]
  def disable_browser_cache
    response.cache_control[:no_cache] = true
    response.cache_control[:extras] = ['no-store', 'max-age=0', 'must-revalidate']
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  # Get the path to an error template
  #
  # This checks for a localized error page, just like the internal Rails code
  # that renders 404/500s.
  #
  # @param [String] error error code to look for
  # @return [String] file path to error page
  def error_page_path(error = '404')
    path = Rails.root.join('public', "#{error}.#{I18n.locale}.html")
    return path if File.exist?(path)

    Rails.root.join('public', "#{error}.html")
  end

  # Send the right parameter sanitizers to Devise
  #
  # Devise in Rails 4 uses this hook in the application controller in order
  # to determine which parameters are accepted across the various account
  # management forms.  When a regular user logs in, delegate to that parameter
  # sanitizer.  Otherwise (e.g., for admin logins in the backend), just use
  # the defaults.
  #
  # This method is not tested, as it's only ever called from within the
  # internals of Devise.
  #
  # @return [Devise::ParameterSanitizer] sanitizer to be used
  # :nocov:
  def devise_parameter_sanitizer
    if resource_class == User
      User::ParameterSanitizer.new(User, :user, params)
    else
      super
    end
  end
  # :nocov:
end
