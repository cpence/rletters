class CreateDownloads < ActiveRecord::Migration[4.2]
  def change
    create_table :downloads do |t|
      t.string :filename

      t.timestamps null: true
    end
  end
end
