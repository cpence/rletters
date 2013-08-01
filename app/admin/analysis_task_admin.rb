# -*- encoding : utf-8 -*-

ActiveAdmin.register AnalysisTask do
  menu :parent => "Datasets"
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
