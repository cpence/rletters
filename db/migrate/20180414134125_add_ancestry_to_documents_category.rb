# frozen_string_literal: true
class AddAncestryToDocumentsCategory < ActiveRecord::Migration[5.2]
  def up
    add_column :documents_categories, :ancestry, :string
    add_index :documents_categories, :ancestry

    Documents::Category.build_ancestry_from_parent_ids!
    Documents::Category.check_ancestry_integrity!

    remove_column :documents_categories, :parent_id
    remove_column :documents_categories, :sort_order

    remove_index :documents_category_hierarchies,
                 column: [:ancestor_id, :descendant_id, :generations],
                 unique: true, name: 'documents_category_anc_desc_udx'
    remove_index :documents_category_hierarchies,
                 column: [:descendant_id],
                 name: 'documents_category_desc_idx'

    drop_table :documents_category_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end
  end

  def down
    # closure_tree doesn't have the methods we need to do this
    fail ActiveRecord::IrreversibleMigration
  end
end
