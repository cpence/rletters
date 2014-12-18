# -*- encoding : utf-8 -*-
class CreateMarkdownPages < ActiveRecord::Migration
  def change
    create_table :markdown_pages do |t|
      t.string :name
      t.text :content

      t.timestamps null: true
    end
  end
end
