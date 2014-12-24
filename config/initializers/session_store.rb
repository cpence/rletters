# Be sure to restart your server when you modify this file.

# Use cookies for sessions, keeping them out of the database
if ActiveRecord::Base.connection.tables.include?('admin_settings')
  key = "_#{Admin::Setting.app_name}_session"
else
  key = '_rletters_session'
end

Rails.application.config.session_store(:cookie_store, key: key)
