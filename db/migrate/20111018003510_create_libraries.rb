class CreateLibraries < ActiveRecord::Migration[4.2]
  def change
    create_table :libraries do |t|
      t.string :name
      t.string :url
      t.references :user

      t.timestamps null: true
    end
    add_index :libraries, :user_id
  end
end
