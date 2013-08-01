# -*- encoding : utf-8 -*-

ActiveAdmin.register CslStyle do
  menu parent: 'settings'
  filter :name

  index do
    column :name
    default_actions
  end
end
