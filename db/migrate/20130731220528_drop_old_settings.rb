class DropOldSettings < ActiveRecord::Migration
  def self.up
    drop_table :settings
  end

  def self.down
    create_table :settings do |t|
      t.string :var, null: false
      t.text :value, null: true
      t.integer :thing_id, null: true
      t.string :thing_type, limit: 30, null: true
      t.timestamps null: true
    end

    add_index :settings, [:thing_type, :thing_id, :var], unique: true
  end
end
