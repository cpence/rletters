# -*- encoding : utf-8 -*-

ActiveAdmin.register Dataset do
  actions :index, :show

  index do
    column :name
    column :user
    column :entries do |dataset|
      dataset.entries.count
    end
    column :analysis_tasks do |dataset|
      dataset.analysis_tasks.count
    end
    default_actions
  end

  filter :user
  filter :name
end
