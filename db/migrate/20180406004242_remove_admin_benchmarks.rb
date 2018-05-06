# frozen_string_literal: true

class RemoveAdminBenchmarks < ActiveRecord::Migration[5.1]
  def change
    drop_table :admin_benchmarks do |t|
      t.string :job
      t.integer :size
      t.float :time

      t.timestamps null: false
    end
  end
end
