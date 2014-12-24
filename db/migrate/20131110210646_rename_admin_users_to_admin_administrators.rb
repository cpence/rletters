class RenameAdminUsersToAdminAdministrators < ActiveRecord::Migration
  def change
    rename_table 'admin_users', 'admin_administrators'
  end
end
