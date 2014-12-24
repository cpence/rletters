class CreateStopLists < ActiveRecord::Migration
  def change
    create_table :stop_lists do |t|
      t.string :language
      t.text :list

      t.timestamps null: true
    end
  end
end
