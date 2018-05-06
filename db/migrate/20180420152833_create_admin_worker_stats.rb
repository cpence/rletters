# frozen_string_literal: true

class CreateAdminWorkerStats < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_worker_stats do |t|
      t.string :worker_type
      t.string :host
      t.integer :pid
      t.datetime :started_at
    end
  end
end
