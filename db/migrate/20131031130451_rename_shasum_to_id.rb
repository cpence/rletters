class RenameShasumToId < ActiveRecord::Migration[4.2]
  def change
    rename_column :dataset_entries, :shasum, :uid
  end
end
