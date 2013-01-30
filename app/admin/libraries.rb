# -*- encoding : utf-8 -*-

ActiveAdmin.register Library do
  menu :parent => "Users"
  actions :index, :show
  
  filter :name
  filter :user
  filter :url
end
