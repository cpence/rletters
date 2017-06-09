class CreateAdminBenchmarks < ActiveRecord::Migration[4.2]
  def change
    create_table :admin_benchmarks do |t|
      t.string :job
      t.integer :size
      t.float :time

      t.timestamps null: false
    end
  end
end
