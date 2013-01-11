# -*- encoding : utf-8 -*-

# Set mailer defaults
RLetters::Application.config.action_mailer.default_url_options = 
  { :host => Settings.app_domain }

