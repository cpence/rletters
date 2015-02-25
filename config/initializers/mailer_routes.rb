
# Set mailer defaults
if ActiveRecord::Base.connection.tables.include?('admin_settings')
  Rails.application.config.action_mailer.default_url_options =
    { host: Admin::Setting.app_domain }
  ActionMailer::Base.default_url_options =
    { host: Admin::Setting.app_domain }
else
  Rails.application.config.action_mailer.default_url_options =
    { host: 'not.a.web.site.com' }
  ActionMailer::Base.default_url_options =
    { host: 'not.a.web.site.com' }
end
