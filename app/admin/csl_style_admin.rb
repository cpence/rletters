# -*- encoding : utf-8 -*-

ActiveAdmin.register CslStyle do
  menu parent: "Settings"
  filter :name

  index do
    column :name
    default_actions
  end
end
