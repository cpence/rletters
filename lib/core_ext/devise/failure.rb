
# A customized failure class for Devise
#
# This class ensures that when we fail to authenticate a user, we redirect
# back to the root page, rather than to the login page (since we no longer
# have a dedicated login action).
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
