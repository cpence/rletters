class AddLastProgressToDatasetsTasks < ActiveRecord::Migration
  def change
    add_column :datasets_tasks, :last_progress, :datetime
  end
end
