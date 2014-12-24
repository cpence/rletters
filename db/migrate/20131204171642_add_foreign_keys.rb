class AddForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key 'datasets_analysis_tasks', 'datasets', name: 'datasets_analysis_tasks_dataset_id_fk'
    add_foreign_key 'datasets_entries', 'datasets', name: 'datasets_entries_dataset_id_fk', on_delete: :cascade
    add_foreign_key 'datasets', 'users', name: 'datasets_user_id_fk', on_delete: :cascade
    add_foreign_key 'documents_categories', 'documents_categories', name: 'documents_categories_parent_id_fk', column: 'parent_id'
    add_foreign_key 'documents_category_hierarchies', 'documents_categories', name: 'documents_category_hierarchies_ancestor_id_fk', column: 'ancestor_id'
    add_foreign_key 'documents_category_hierarchies', 'documents_categories', name: 'documents_category_hierarchies_descendant_id_fk', column: 'descendant_id'
    add_foreign_key 'users_libraries', 'users', name: 'users_libraries_user_id_fk', on_delete: :cascade
  end
end
