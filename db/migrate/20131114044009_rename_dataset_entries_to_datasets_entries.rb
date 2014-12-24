class RenameDatasetEntriesToDatasetsEntries < ActiveRecord::Migration
  def change
    rename_table 'dataset_entries', 'datasets_entries'
  end
end
