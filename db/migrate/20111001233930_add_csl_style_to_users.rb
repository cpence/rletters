# -*- encoding : utf-8 -*-
class AddCslStyleToUsers < ActiveRecord::Migration
  def up
    add_column :users, :csl_style, :string, default: ""
    User.update_all ["csl_style = ?", ""]
  end

  def down
    remove_column :users, :csl_style
  end
end
