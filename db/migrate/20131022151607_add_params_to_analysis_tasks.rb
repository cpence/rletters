class AddParamsToAnalysisTasks < ActiveRecord::Migration[4.2]
  def change
    add_column :analysis_tasks, :params, :text
  end
end
