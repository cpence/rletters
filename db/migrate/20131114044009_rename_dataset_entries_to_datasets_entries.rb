class RenameDatasetEntriesToDatasetsEntries < ActiveRecord::Migration[4.2]
  def change
    rename_table 'dataset_entries', 'datasets_entries'
  end
end
