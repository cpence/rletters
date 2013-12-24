# -*- encoding : utf-8 -*-
class AddResqueKeyToDatasetsAnalysisTasks < ActiveRecord::Migration
  def change
    add_column :datasets_analysis_tasks, :resque_key, :string
  end
end
