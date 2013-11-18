# -*- encoding : utf-8 -*-

# Set mailer defaults
if ActiveRecord::Base.connection.tables.include?('admin_settings')
  RLetters::Application.config.action_mailer.default_url_options =
    { host: Admin::Setting.app_domain }
else
  RLetters::Application.config.action_mailer.default_url_options =
    { host: 'not.a.web.site.com' }
end
