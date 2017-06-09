class CreateCslStyles < ActiveRecord::Migration[4.2]
  def change
    create_table :csl_styles do |t|
      t.string :name
      t.text :style

      t.timestamps null: true
    end
  end
end
