# -*- encoding : utf-8 -*-

# Set mailer defaults
if ActiveRecord::Base.connection.tables.include?('settings')
  RLetters::Application.config.action_mailer.default_url_options = 
    { :host => Settings.app_domain }
end

