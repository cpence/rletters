# -*- encoding : utf-8 -*-

# Devise's user notification mailer
class DeviseMailer < Devise::Mailer
  include Resque::Mailer
  include Devise::Controllers::UrlHelpers

  default from: 'noreply@example.com'
  layout 'ink_email'
end
