
ActiveAdmin.register Admin::Benchmark do
  actions :index, :show
  menu parent: 'Settings'

  index do
    selectable_column
    column :job
    column :size
    column :time
    actions
  end

  filter :job
  filter :size
end
