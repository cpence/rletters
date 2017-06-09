class CreateUploadedAssets < ActiveRecord::Migration[4.2]
  def change
    create_table :uploaded_assets do |t|
      t.string :name
      t.attachment :file
      t.text :file_meta
      t.string :file_fingerprint
      t.timestamps null: true
    end
  end
end
