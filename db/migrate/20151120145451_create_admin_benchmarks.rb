class CreateAdminBenchmarks < ActiveRecord::Migration
  def change
    create_table :admin_benchmarks do |t|
      t.string :job
      t.integer :size
      t.float :time

      t.timestamps null: false
    end
  end
end
