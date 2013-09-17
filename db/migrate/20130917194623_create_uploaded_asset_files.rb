# -*- encoding : utf-8 -*-
class CreateUploadedAssetFiles < ActiveRecord::Migration
  def self.up
    create_table :uploaded_asset_files do |t|
      t.integer    :uploaded_asset_id
      t.string     :style
      t.binary     :file_contents
    end
  end

  def self.down
    drop_table :uploaded_asset_files
  end
end
