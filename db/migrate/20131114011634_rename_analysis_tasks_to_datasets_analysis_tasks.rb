class RenameAnalysisTasksToDatasetsAnalysisTasks < ActiveRecord::Migration[4.2]
  def change
    rename_table 'analysis_tasks', 'datasets_analysis_tasks'
    rename_table 'analysis_task_results', 'datasets_analysis_task_results'
    rename_column :datasets_analysis_task_results, 'analysis_task_id', 'datasets_analysis_task_id'
  end
end
