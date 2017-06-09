class AddResqueKeyToDatasetsAnalysisTasks < ActiveRecord::Migration[4.2]
  def change
    add_column :datasets_analysis_tasks, :resque_key, :string
  end
end
