# -*- encoding : utf-8 -*-

ActiveAdmin.register Users::CslStyle do
  menu parent: 'settings'
  filter :name

  index do
    column :name
    default_actions
  end

  # :nocov:
  controller do
    def permitted_params
      params.permit csl_style: [:name, :style]
    end
  end
  # :nocov:
end
