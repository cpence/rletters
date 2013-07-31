class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :key
      t.text :value

      t.timestamps
    end
    add_index :settings, [:key], :unique => true, :name => 'key_udx'
  end
end
