# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.

# Use cookies for sessions, keeping them out of the database
if ActiveRecord::Base.connection.tables.include?('setting')
  RLetters::Application.config.session_store :cookie_store, key: "_#{Setting.app_name}_session"
else
  RLetters::Application.config.session_store :cookie_store, key: "_rletters_session"
end
