# frozen_string_literal: true

class AddExportRequestedAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :export_requested_at, :datetime
  end
end
