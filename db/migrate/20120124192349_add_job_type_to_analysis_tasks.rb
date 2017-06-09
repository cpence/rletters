class AddJobTypeToAnalysisTasks < ActiveRecord::Migration[4.2]
  def change
    add_column :analysis_tasks, :job_type, :string
  end
end
