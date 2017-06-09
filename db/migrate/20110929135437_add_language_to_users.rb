class AddLanguageToUsers < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :language, :string, default: 'en-US'
    execute "UPDATE users SET language='en-US'"
  end

  def down
    remove_column :users, :language
  end
end
