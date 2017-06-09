class RenameLibrariesToUsersLibraries < ActiveRecord::Migration[4.2]
  def change
    rename_table 'libraries', 'users_libraries'
  end
end
