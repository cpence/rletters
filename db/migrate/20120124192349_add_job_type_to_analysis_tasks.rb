class AddJobTypeToAnalysisTasks < ActiveRecord::Migration
  def change
    add_column :analysis_tasks, :job_type, :string
  end
end
