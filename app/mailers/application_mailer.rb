
# Base class for all application mailers
class ApplicationMailer < ActionMailer::Base
  default from: ENV['APP_EMAIL'] || 'noreply@example.com'
  layout 'mailer'
end
