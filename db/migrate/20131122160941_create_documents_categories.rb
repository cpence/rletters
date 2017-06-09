class CreateDocumentsCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :documents_categories do |t|
      t.integer :parent_id
      t.integer :sort_order
      t.string :name
      t.text :journals

      t.timestamps null: true
    end

    # The following comes directly from closure_table
    create_table :documents_category_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :documents_category_hierarchies,
              [:ancestor_id, :descendant_id, :generations],
              unique: true, name: 'documents_category_anc_desc_udx'

    add_index :documents_category_hierarchies, [:descendant_id],
              name: 'documents_category_desc_idx'
  end
end
