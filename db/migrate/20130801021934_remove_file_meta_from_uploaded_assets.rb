class RemoveFileMetaFromUploadedAssets < ActiveRecord::Migration[4.2]
  def change
    remove_column :uploaded_assets, :file_meta, :text
  end
end
