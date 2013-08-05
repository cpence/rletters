# -*- encoding : utf-8 -*-
class RemoveFileMetaFromUploadedAssets < ActiveRecord::Migration
  def change
    remove_column :uploaded_assets, :file_meta, :text
  end
end
