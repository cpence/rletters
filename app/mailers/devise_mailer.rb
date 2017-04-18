
# Devise's user notification mailer
#
# We override this class in order to use our custom mail layout.
class DeviseMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers

  default from: ENV['APP_EMAIL'] || 'noreply@example.com'
  layout 'mailer'
end
