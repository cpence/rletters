class CreateCslStyles < ActiveRecord::Migration
  def change
    create_table :csl_styles do |t|
      t.string :name
      t.text :style

      t.timestamps null: true
    end
  end
end
