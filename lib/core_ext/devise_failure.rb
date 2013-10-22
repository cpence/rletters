# -*- encoding : utf-8 -*-

class DeviseFailure < Devise::FailureApp
  def redirect_url
    if scope == :admin_user
      # For administrators, we want to redirect to the login page
      super
    else
      root_url
    end
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
