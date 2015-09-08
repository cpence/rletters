class CreateDatasetsFiles < ActiveRecord::Migration
  def up
    # Make the new table
    create_table :datasets_files do |t|
      t.string :description
      t.string :short_description
      t.references :task
      t.attachment :result

      t.timestamps null: false
    end

    # Create new file objects for each of the old files in the DB
    Datasets::Task.all.each do |task|
      if task.result_file_size > 0
        file = Datasets::File.new(description: 'Old Task Result',
                                  short_description: 'Result',
                                  task: task,
                                  result: task.result)
      end
    end

    # Blow up the old storage
    drop_attached_file :datasets_tasks, :result
  end

  def down
    # We're going from one-one to one-many, you can't reverse this. Sorry!
    fail ActiveRecord::IrreversibleMigration
  end
end
