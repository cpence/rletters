class AddFailedToAnalysisTasks < ActiveRecord::Migration[4.2]
  def change
    add_column :analysis_tasks, :failed, :boolean, default: false
  end
end
