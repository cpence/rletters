class AddWorkflowToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :workflow_active, :boolean, default: false
    add_column :users, :workflow_class, :string
    add_column :users, :workflow_datasets, :string
  end
end
