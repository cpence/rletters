# -*- encoding : utf-8 -*-
class CreateUploadedAssets < ActiveRecord::Migration
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
