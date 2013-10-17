# -*- encoding : utf-8 -*-
class AddWorkflowToUsers < ActiveRecord::Migration
  def change
    add_column :users, :workflow_active, :boolean, default: false
    add_column :users, :workflow_class, :string
    add_column :users, :workflow_datasets, :string
  end
end
