# -*- encoding : utf-8 -*-
class RenameShasumToId < ActiveRecord::Migration
  def change
    rename_column :dataset_entries, :shasum, :uid
  end
end
