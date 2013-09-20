# -*- encoding : utf-8 -*-
class CreateStopLists < ActiveRecord::Migration
  def change
    create_table :stop_lists do |t|
      t.string :language
      t.text :list

      t.timestamps
    end
  end
end
