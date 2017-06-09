class AddJobIdToDatasetsTasks < ActiveRecord::Migration[4.2]
  def change
    add_column :datasets_tasks, :job_id, :string
  end
end
