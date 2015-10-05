class DropSettings < ActiveRecord::Migration
  def change
    drop_table :admin_settings do |t|
      t.string :key
      t.text :value

      t.timestamps null: true
    end
  end
end
