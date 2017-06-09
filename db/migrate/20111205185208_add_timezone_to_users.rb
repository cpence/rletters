class AddTimezoneToUsers < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :timezone, :string,
               default: 'Eastern Time (US & Canada)'
    execute "UPDATE users SET timezone='Eastern Time (US & Canada)'"
  end

  def down
    remove_column :users, :timezone
  end
end
