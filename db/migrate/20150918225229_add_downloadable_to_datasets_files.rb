class AddDownloadableToDatasetsFiles < ActiveRecord::Migration
  def change
    add_column :datasets_files, :downloadable, :boolean, default: false
  end
end
