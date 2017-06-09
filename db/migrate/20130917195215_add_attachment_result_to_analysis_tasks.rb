class AddAttachmentResultToAnalysisTasks < ActiveRecord::Migration[4.2]
  def self.up
    change_table :analysis_tasks do |t|
      t.attachment :result
    end

    drop_table :downloads
  end

  def self.down
    create_table :downloads do |t|
      t.string :filename
      t.references :analysis_task

      t.timestamps null: true
    end
    add_index :downloads, :analysis_task_id

    drop_attached_file :analysis_tasks, :result
  end
end
