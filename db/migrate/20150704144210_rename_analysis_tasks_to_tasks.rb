class RenameAnalysisTasksToTasks < ActiveRecord::Migration
  def change
    rename_table :datasets_analysis_tasks, :datasets_tasks
    rename_table :datasets_analysis_task_results, :datasets_task_results
    rename_column :datasets_task_results, :datasets_analysis_task_id, :datasets_task_id
  end
end
