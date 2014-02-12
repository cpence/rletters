# -*- encoding : utf-8 -*-
class ChangeCslStyleToId < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.remove :csl_style
      t.integer :csl_style_id
    end
  end

  def down
    change_table :users do |t|
      t.remove :csl_style_id
      t.string :csl_style, default: ''
    end
    execute "UPDATE users SET csl_style=''"
  end
end
