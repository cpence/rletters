# -*- encoding : utf-8 -*-
class ChangeLanguageDefaultToEn < ActiveRecord::Migration
  def up
    change_column :users, :language, :string, default: 'en'
    User.where(language: 'en-US').update_all(language: 'en')
  end

  def down
    add_column :users, :language, :string, default: 'en-US'
    User.where(language: 'en').update_all(language: 'en-US')
  end
end
