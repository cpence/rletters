class AddFetchToDatasets < ActiveRecord::Migration[4.2]
  def change
    add_column :datasets, :fetch, :boolean, default: false
  end
end
