class AddLastProgressToDatasetsTasks < ActiveRecord::Migration[4.2]
  def change
    add_column :datasets_tasks, :last_progress, :datetime
  end
end
