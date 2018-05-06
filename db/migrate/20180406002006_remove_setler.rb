# frozen_string_literal: true
class RemoveSetler < ActiveRecord::Migration[5.1]
  def up
    drop_table :admin_feature_flags
  end

  def down
    create_table(:admin_feature_flags) do |t|
      t.string :var, null: false
      t.text :value, null: true
      t.integer :thing_id, null: true
      t.string :thing_type, limit: 30, null: true
      t.timestamps null: false
    end

    add_index :admin_feature_flags, [:thing_type, :thing_id, :var], unique: true
  end
end
