class AddDisabledToDatasets < ActiveRecord::Migration
  def up
    add_column :datasets, :disabled, :boolean
    execute "UPDATE datasets SET disabled=#{ActiveRecord::Base.connection.quoted_false}"
  end

  def down
    remove_column :datasets, :disabled
  end
end
