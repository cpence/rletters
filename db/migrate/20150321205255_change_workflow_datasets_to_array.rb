class ChangeWorkflowDatasetsToArray < ActiveRecord::Migration[4.2]
  def up
    User.all.each do |u|
      if u.workflow_datasets
        u.workflow_datasets = u.workflow_datasets.join(',')
      else
        u.workflow_datasets = ''
      end
      u.save
    end

    change_column(
      :users, :workflow_datasets,
      "text[] USING (string_to_array(workflow_datasets, ','))"
    )
    change_column_default :users, :workflow_datasets, []
  end

  def down
    change_column :users, :workflow_datasets, :text, array: false, default: ''
  end
end
