# -*- encoding : utf-8 -*-
class AddLanguageToUsers < ActiveRecord::Migration
  def up
    add_column :users, :language, :string, default: 'en-US'
    execute "UPDATE users SET language='en-US'"
  end

  def down
    remove_column :users, :language
  end
end
