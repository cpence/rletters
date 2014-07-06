# -*- encoding : utf-8 -*-

# A customized failure class for Devise
#
# This class ensures that when we fail to authenticate a user, we redirect
# back to the root page, rather than to the login page (since we no longer
# have a dedicated login action).
class DeviseFailure < Devise::FailureApp
  # The redirection URL on failure
  #
  # For regular users, return the root path.  Make sure not to do that, though,
  # for administrators, who do in fact need to be redirected to the admin
  # login page.
  #
  # @api private
  # @return [String] the URL for redirection
  def redirect_url
    if scope == :administrator
      # For administrators, we want to redirect to the login page
      super
    else
      root_url
    end
  end

  # Redirect on all failures
  #
  # This does not include support for HTTP basic authentication, which is fine,
  # because we don't want that.
  #
  # @api private
  # @return [void]
  def respond
    redirect
  end
end
