class RemovePaperclipColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :admin_uploaded_assets, :file_file_name, :string
    remove_column :admin_uploaded_assets, :file_content_type, :string
    remove_column :admin_uploaded_assets, :file_file_size, :integer
    remove_column :admin_uploaded_assets, :file_updated_at, :datetime
    remove_column :admin_uploaded_assets, :file_fingerprint, :string

    remove_column :datasets_files, :result_file_name, :string
    remove_column :datasets_files, :result_content_type, :string
    remove_column :datasets_files, :result_file_size, :integer
    remove_column :datasets_files, :result_updated_at, :datetime
  end
end
