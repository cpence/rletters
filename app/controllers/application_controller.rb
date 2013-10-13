# -*- encoding : utf-8 -*-

# The main application controller for RLetters
#
# This controller implements functionality shared throughout the entire
# RLetters site.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Redirect to the root on successful sign in
  #
  # This method is called by Devise.
  #
  # @api private
  # @return [undefined]
  def after_sign_in_path_for(resource)
    if resource.is_an?(AdminUser)
      admin_root_url
    else
      root_url
    end
  end

  # Redirect to the root on successful sign out
  #
  # This method is called by Devise.
  #
  # @api private
  # @return [undefined]
  def after_sign_out_path_for(resource)
    root_url
  end

  private

  before_filter :set_locale, :set_timezone, :ensure_trailing_slash

  # Set the locale if the user is logged in
  #
  # This function is called as a +before_filter+ in all controllers, you do
  # not need to call it yourself.  Do not disable it, or the locale system
  # will go haywire.
  #
  # @api private
  # @return [undefined]
  def set_locale
    if user_signed_in?
      I18n.locale = current_user.language.to_sym
    else
      I18n.locale = I18n.default_locale
    end
  end

  # Set the timezone if the user is logged in
  #
  # This function is called as a +before_filter+ in all controllers, you do
  # not need to call it yourself.  Do not disable it, or the timezone system
  # will go haywire.
  #
  # @api private
  # @return [undefined]
  def set_timezone
    if user_signed_in?
      Time.zone = current_user.timezone
    else
      Time.zone = 'Eastern Time (US & Canada)'
    end
  end

  # Make sure there's a trailing slash on the URL
  #
  # jQuery Mobile really wants us always to have a trailing slash on our
  # URLs, since we often are redirecting to subdirectory pages (e.g., from
  # /datasets/ to /datasets/2/ to /datasets/2/task/3/results/, etc.).  This
  # helper makes sure we've always got a trailing slash.  Don't disable it!
  #
  # @api private
  # @return [undefined]
  def ensure_trailing_slash
    redirect_to url_for(params.merge(trailing_slash: true)),
                status: 301 unless trailing_slash?
  end

  # Does the URL end with a trailing slash?
  # @api private
  # @return [Boolean] true if request URL ends with /
  def trailing_slash?
    # If fullpath isn't defined (e.g., in testing), then just return true
    # so we don't do unnecessary redirects.
    return true if request.env['REQUEST_URI'].blank?

    request.env['REQUEST_URI'].match(/[^\?]+/).to_s.last == '/'
  end

  protected

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
  # @api private
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
