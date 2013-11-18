# -*- encoding : utf-8 -*-
class RenameSettingsToAdminSettings < ActiveRecord::Migration
  def change
    rename_table 'settings', 'admin_settings'
  end
end
