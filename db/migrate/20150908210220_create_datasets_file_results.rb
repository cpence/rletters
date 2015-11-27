class CreateDatasetsFileResults < ActiveRecord::Migration
  def self.up
    create_table :datasets_file_results do |t|
      t.integer :datasets_file_id
      t.string :style
      t.binary :file_contents
    end

    drop_table :datasets_task_results
  end

  def self.down
    # This is really part of the last migration, which is also irreversible
    fail ActiveRecord::IrreversibleMigration
  end
end
