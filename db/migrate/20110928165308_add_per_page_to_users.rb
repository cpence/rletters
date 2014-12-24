class AddPerPageToUsers < ActiveRecord::Migration
  def up
    add_column :users, :per_page, :integer, default: 10
    execute 'UPDATE users SET per_page=10'
  end

  def down
    remove_column :users, :per_page
  end
end
