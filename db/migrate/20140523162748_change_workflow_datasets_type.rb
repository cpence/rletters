class ChangeWorkflowDatasetsType < ActiveRecord::Migration
  def up
    # Skip the callback that requires the data to be in the new format when
    # migrating it for the first time
    User.skip_callback(:save, :after_save, :workflow_datasets_from_ids)
    User.skip_callback(:find, :after_find, :workflow_datasets_from_ids)

    # Save the current value of the parameter
    workflow_datasets = {}
    User.all.each do |u|
      if u.workflow_datasets.present?
        workflow_datasets[u] = u.workflow_datasets
      end
    end

    change_column :users, :workflow_datasets, :text

    # Write new data into the database
    workflow_datasets.each do |u, datasets|
      u.workflow_datasets = JSON.parse(datasets)
      u.save
    end
  end

  def down
    # Save the current value of the parameter
    workflow_datasets = {}
    User.all.each do |u|
      if u.workflow_datasets.present?
        workflow_datasets[u] = u.workflow_datasets
      end
    end

    change_column :users, :workflow_datasets, :string

    # Write new data into the database
    workflow_datasets.each do |u, datasets|
      u.workflow_datasets = datasets.map { |id| id }.to_json
      u.save
    end
  end
end
