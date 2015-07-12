
ActiveAdmin.register Datasets::Task do
  menu parent: 'datasets'
  actions :index, :show

  config.sort_order = 'created_at_desc'

  index do
    selectable_column
    column :job_type
    column :name
    column :dataset
    column :created_at
    column :finished_at
    column :failed
    actions
  end

  filter :job_type
  filter :dataset
  filter :name
  filter :failed
end
