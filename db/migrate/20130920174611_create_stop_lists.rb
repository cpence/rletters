class CreateStopLists < ActiveRecord::Migration[4.2]
  def change
    create_table :stop_lists do |t|
      t.string :language
      t.text :list

      t.timestamps null: true
    end
  end
end
