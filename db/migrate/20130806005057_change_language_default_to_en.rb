# -*- encoding : utf-8 -*-
class ChangeLanguageDefaultToEn < ActiveRecord::Migration
  def up
    change_column :users, :language, :string, default: 'en'
    execute "UPDATE users SET language='en' WHERE language='en-US'"
  end

  def down
    add_column :users, :language, :string, default: 'en-US'
    execute "UPDATE users SET language='en-US' WHERE language='en'"
  end
end
