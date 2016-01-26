class AddJobIdToDatasetsTasks < ActiveRecord::Migration
  def change
    add_column :datasets_tasks, :job_id, :string
  end
end
