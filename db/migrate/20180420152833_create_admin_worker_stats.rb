# frozen_string_literal: true

# Intentionally not doing Rails's timestamps here, as we don't want to add
# any bloat to the DB if we don't have to.
# rubocop:disable CreateTableWithTimestamps

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

# rubocop:enable CreateTableWithTimestamps
