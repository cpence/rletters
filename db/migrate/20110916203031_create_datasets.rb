class CreateDatasets < ActiveRecord::Migration
  def change
    create_table :datasets do |t|
      t.string :name
      t.references :user

      t.timestamps null: true
    end
    add_index :datasets, :user_id
  end
end
