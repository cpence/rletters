class AddParamsToAnalysisTasks < ActiveRecord::Migration
  def change
    add_column :analysis_tasks, :params, :text
  end
end
