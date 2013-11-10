# -*- encoding : utf-8 -*-

ActiveAdmin.register Users::Library do
  menu parent: 'users'
  actions :index, :show

  filter :name
  filter :user
  filter :url
end
