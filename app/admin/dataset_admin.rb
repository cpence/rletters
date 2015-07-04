
ActiveAdmin.register Dataset do
  actions :index, :show

  config.sort_order = 'created_at_desc'

  index do
    selectable_column
    column :name
    column :user
    column :disabled
    column :entries do |dataset|
      dataset.entries.size
    end
    column :tasks do |dataset|
      dataset.tasks.size
    end
    actions
  end

  filter :user
  filter :name
  filter :disabled
end
