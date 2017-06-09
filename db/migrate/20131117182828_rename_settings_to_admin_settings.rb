class RenameSettingsToAdminSettings < ActiveRecord::Migration[4.2]
  def change
    rename_table 'settings', 'admin_settings'
  end
end
