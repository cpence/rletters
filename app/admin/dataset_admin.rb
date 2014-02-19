# -*- encoding : utf-8 -*-

ActiveAdmin.register Dataset do
  actions :index, :show

  index do
    column :name
    column :user
    column :disabled
    column :entries do |dataset|
      dataset.entries.size
    end
    column :analysis_tasks do |dataset|
      dataset.analysis_tasks.size
    end
    default_actions
  end

  filter :user
  filter :name
  filter :disabled
end
