# -*- encoding : utf-8 -*-
class RenameLibrariesToUsersLibraries < ActiveRecord::Migration
  def change
    rename_table 'libraries', 'users_libraries'
  end
end
