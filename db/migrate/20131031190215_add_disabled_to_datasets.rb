# -*- encoding : utf-8 -*-
class AddDisabledToDatasets < ActiveRecord::Migration
  def up
    add_column :datasets, :disabled, :boolean
    Datasets.all.each { |d| d.disabled = false; d.save! }
  end

  def down
    remove_column :datasets, :disabled
  end
end
