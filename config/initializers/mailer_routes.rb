# -*- encoding : utf-8 -*-

# Set mailer defaults
#### FIXME FIXME FIXME Is this going to work?!
RLetters::Application.config.action_mailer.default_url_options = 
  { :host => Settings.app_domain }

