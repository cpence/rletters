
# Base class for all application mailers
class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  default from: ENV['APP_EMAIL'] || 'noreply@example.com'
  layout 'ink_email'
end
