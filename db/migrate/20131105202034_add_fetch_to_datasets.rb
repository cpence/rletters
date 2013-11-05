# -*- encoding : utf-8 -*-
class AddFetchToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :fetch, :boolean, default: false
  end
end
