# frozen_string_literal: true

# Base class for all application mailers
class ApplicationMailer < ActionMailer::Base
  default from: ENV['APP_EMAIL'] || 'noreply@example.com'
  layout 'mailer'

  # We need the asset URL helper in the mailer views
  helper 'admin/asset'
end
