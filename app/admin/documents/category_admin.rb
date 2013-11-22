# -*- encoding : utf-8 -*-

ActiveAdmin.register Documents::Category do
  menu parent: 'admin_settings'
  config.filters = false

  sortable tree: true,
           sorting_attribute: :sort_order,
           parent_method: :parent,
           children_method: :children,
           roots_method: :roots,
           collapsible: true

  index as: :sortable do
    label :name
    actions
  end
end
