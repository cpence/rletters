# frozen_string_literal: true
class RemoveDatabaseFileTables < ActiveRecord::Migration[5.1]
  def up
    drop_table :datasets_file_results do |t|
      t.integer :datasets_file_id
      t.string :style
      t.binary :file_contents
    end

    drop_table :admin_uploaded_asset_files do |t|
      t.integer :uploaded_asset_id
      t.string :style
      t.binary :file_contents
    end
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
