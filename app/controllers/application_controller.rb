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
    if resource.is_a?(Admin::Administrator)
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

  before_action :set_locale, :set_timezone

  # Set the locale if the user is logged in
  #
  # This function is called as a +before_action+ in all controllers, you do
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
  # This function is called as a +before_action+ in all controllers, you do
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
