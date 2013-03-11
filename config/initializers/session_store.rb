# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.

# Use cookies for sessions, keeping them out of the database
RLetters::Application.config.session_store :cookie_store, key: "_#{Settings.app_name}_session"
