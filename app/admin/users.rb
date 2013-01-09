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
  filter :language, :as => :select, :collection => proc { APP_CONFIG['available_locales'] }
  filter :time_zone
  filter :csl_style
  filter :created_at
  filter :updated_at
  filter :current_sign_in_at
  filter :last_sign_in_at
  filter :current_sign_in_ip
  filter :last_sign_in_ip
end
