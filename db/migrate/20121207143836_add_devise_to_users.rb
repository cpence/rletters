# -*- encoding : utf-8 -*-
class AddDeviseToUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      ## Database authenticatable
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Clear out old stuff
      t.remove :identifier
    end

    ## Change email column
    change_column :users, :email, :string, null: false, default: ''

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
  end

  def self.down
    change_table(:users) do |t|
      ## Remove new stuff
      t.remove :encrypted_password

      t.remove :reset_password_token
      t.remove :reset_password_sent_at

      t.remove :remember_created_at

      t.remove :sign_in_count
      t.remove :current_sign_in_at
      t.remove :last_sign_in_at
      t.remove :current_sign_in_ip
      t.remove :last_sign_in_ip

      ## Put back old stuff
      t.string :identifier
      t.remove :email
      t.string :email
    end

    # Reset email options
    change_column :users, :email, :string, null: true, default: nil
  end
end
