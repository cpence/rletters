# frozen_string_literal: true
class DropCslStyles < ActiveRecord::Migration[5.2]
  def change
    drop_table 'users_csl_styles' do |t|
      t.string "name"
      t.text "style"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    remove_column :users, :csl_style_id, :integer
  end
end
