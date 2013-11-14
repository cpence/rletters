# -*- encoding : utf-8 -*-

ActiveAdmin.register Datasets::AnalysisTask do
  menu parent: 'datasets'
  actions :index, :show

  index do
    column :job_type
    column :name
    column :dataset
    column :created_at
    column :finished_at
    column :failed
    default_actions
  end

  filter :job_type
  filter :dataset
  filter :name
  filter :failed
end
