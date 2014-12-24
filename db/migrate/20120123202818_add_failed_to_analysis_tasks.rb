class AddFailedToAnalysisTasks < ActiveRecord::Migration
  def change
    add_column :analysis_tasks, :failed, :boolean, default: false
  end
end
