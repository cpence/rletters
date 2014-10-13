# -*- encoding : utf-8 -*-

# Devise's user notification mailer
#
# We override this class in order to use our custom mail layout.
class DeviseMailer < Devise::Mailer
  include Resque::Mailer
  include Roadie::Rails::Automatic
  include Devise::Controllers::UrlHelpers

  default from: 'noreply@example.com'
  layout 'ink_email'
end
