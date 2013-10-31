# -*- encoding : utf-8 -*-
class AddDisabledToDatasets < ActiveRecord::Migration
  def change
    add_column :datasets, :disabled, :boolean
  end
end
