# frozen_string_literal: true
class AddExportToUsers < ActiveRecord::Migration[5.2]
  def up
    add_attachment :users, :export_archive
  end
  def down
    remove_attachment :users, :export_archive
  end
end
