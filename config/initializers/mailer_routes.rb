# -*- encoding : utf-8 -*-

# Set mailer defaults
if ActiveRecord::Base.connection.tables.include?('setting')
  RLetters::Application.config.action_mailer.default_url_options =
    { host: Setting.app_domain }
else
  RLetters::Application.config.action_mailer.default_url_options =
    { host: 'not.a.web.site.com' }
end
