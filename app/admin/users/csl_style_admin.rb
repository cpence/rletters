
ActiveAdmin.register Users::CslStyle do
  menu parent: 'Settings'
  filter :name

  permit_params :name, :style

  index do
    selectable_column
    column :name
    actions
  end
end
