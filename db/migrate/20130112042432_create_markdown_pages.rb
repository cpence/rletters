class CreateMarkdownPages < ActiveRecord::Migration[4.2]
  def change
    create_table :markdown_pages do |t|
      t.string :name
      t.text :content

      t.timestamps null: true
    end
  end
end
