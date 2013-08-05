# -*- encoding : utf-8 -*-
class AddPerPageToUsers < ActiveRecord::Migration
  def up
    add_column :users, :per_page, :integer, default: 10
    User.update_all ['per_page = ?', 10]
  end

  def down
    remove_column :users, :per_page
  end
end
