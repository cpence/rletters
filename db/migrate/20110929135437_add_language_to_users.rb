# -*- encoding : utf-8 -*-
class AddLanguageToUsers < ActiveRecord::Migration
  def up
    add_column :users, :language, :string, default: 'en-US'
    User.update_all ['language = ?', 'en-US']
  end

  def down
    remove_column :users, :language
  end
end
