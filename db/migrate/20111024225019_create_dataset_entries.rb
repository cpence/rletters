# -*- encoding : utf-8 -*-
class CreateDatasetEntries < ActiveRecord::Migration
  def change
    create_table :dataset_entries do |t|
      t.string :shasum
      t.references :dataset

      t.timestamps null: true
    end
    add_index :dataset_entries, :dataset_id
  end
end
