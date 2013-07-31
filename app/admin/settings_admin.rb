# -*- encoding : utf-8 -*-

ActiveAdmin.register Setting do
  actions :index, :update, :edit
  config.filters = false
  config.batch_actions = false
  
  index do
    column :friendly_name
    column :value
    default_actions
  end
  
  form do |f|
    f.inputs "Setting: #{f.friendly_name}" do
      f.input :value
    end
    f.buttons
  end
end
