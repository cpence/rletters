class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :identifier

      t.timestamps null: true
    end
  end
end
