class RemovePerPageFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :per_page
  end

  def down
    add_column :users, :per_page, :integer, default: 10
    execute 'UPDATE users SET per_page=10'
  end
end
