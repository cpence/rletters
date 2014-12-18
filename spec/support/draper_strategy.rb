
# We have to give some empty stubs for all the methods that we're going to
# mock with RSpec, because RSpec only lets us mock methods that already exist
# in the class.
module DraperHelperProxyStubs
  def current_user; end
  def user_signed_in?; end
  def render(h); end
end

Draper::HelperProxy.include(DraperHelperProxyStubs)

# Every decorator needs a params helper, that starts with a fresh hash every
# request
module DraperHelpers
  def params
    @params ||= {}
    @params
  end
end

Draper::ViewContext.test_strategy :fast do
  include DraperHelpers
  include Rails.application.routes.url_helpers
end
