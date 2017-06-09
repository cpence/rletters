class AddDownloadableToDatasetsFiles < ActiveRecord::Migration[4.2]
  def change
    add_column :datasets_files, :downloadable, :boolean, default: false
  end
end
