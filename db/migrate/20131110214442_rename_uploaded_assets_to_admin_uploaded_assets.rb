class RenameUploadedAssetsToAdminUploadedAssets < ActiveRecord::Migration[4.2]
  def change
    rename_table 'uploaded_assets', 'admin_uploaded_assets'
    rename_table 'uploaded_asset_files', 'admin_uploaded_asset_files'
    rename_column :admin_uploaded_asset_files, 'uploaded_asset_id', 'admin_uploaded_asset_id'
  end
end
