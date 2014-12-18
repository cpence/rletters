# -*- encoding : utf-8 -*-
class CreateAnalysisTasks < ActiveRecord::Migration
  def change
    create_table :analysis_tasks do |t|
      t.string :name
      t.datetime :finished_at
      t.references :dataset

      t.timestamps null: true
    end
    add_index :analysis_tasks, :dataset_id

    change_table :downloads do |t|
      t.references :analysis_task
    end
    add_index :downloads, :analysis_task_id
  end
end
