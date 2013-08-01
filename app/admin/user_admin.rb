# -*- encoding : utf-8 -*-

ActiveAdmin.register User do
  actions :index, :show

  index do
    column :name
    column :email
    column :last_sign_in_at
    column :last_sign_in_ip
    default_actions
  end

  filter :name
  filter :email
  filter :language, :as => :select, :collection => proc { Rails.application.config.i18n.available_locales }
  filter :time_zone
  filter :created_at
  filter :updated_at
  filter :current_sign_in_at
  filter :last_sign_in_at
  filter :current_sign_in_ip
  filter :last_sign_in_ip
end
