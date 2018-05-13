# frozen_string_literal: true

class RemoveFetchFromDatasets < ActiveRecord::Migration[5.2]
  def change
    remove_column :datasets, :fetch, :boolean, default: false
  end
end
