class CreateDatasets < ActiveRecord::Migration[4.2]
  def change
    create_table :datasets do |t|
      t.string :name
      t.references :user

      t.timestamps null: true
    end
    add_index :datasets, :user_id
  end
end
