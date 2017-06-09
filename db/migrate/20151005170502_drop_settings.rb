class DropSettings < ActiveRecord::Migration[4.2]
  def change
    drop_table :admin_settings do |t|
      t.string :key
      t.text :value

      t.timestamps null: true
    end
  end
end
