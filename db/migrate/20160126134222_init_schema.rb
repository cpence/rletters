# frozen_string_literal: true

class InitSchema < ActiveRecord::Migration[5.0]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    create_table "admin_administrators", id: :serial, force: :cascade do |t|
      t.string "email", default: "", null: false
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer "sign_in_count", default: 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string "current_sign_in_ip"
      t.string "last_sign_in_ip"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["email"], name: "index_admin_administrators_on_email", unique: true
      t.index ["reset_password_token"], name: "index_admin_administrators_on_reset_password_token", unique: true
    end
    create_table "admin_benchmarks", id: :serial, force: :cascade do |t|
      t.string "job"
      t.integer "size"
      t.float "time"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "admin_feature_flags", id: :serial, force: :cascade do |t|
      t.string "var", null: false
      t.text "value"
      t.integer "thing_id"
      t.string "thing_type", limit: 30
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["thing_type", "thing_id", "var"], name: "index_admin_feature_flags_on_thing_type_and_thing_id_and_var", unique: true
    end
    create_table "admin_markdown_pages", id: :serial, force: :cascade do |t|
      t.string "name"
      t.text "content"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "admin_uploaded_asset_files", id: :serial, force: :cascade do |t|
      t.integer "admin_uploaded_asset_id"
      t.string "style"
      t.binary "file_contents"
    end
    create_table "admin_uploaded_assets", id: :serial, force: :cascade do |t|
      t.string "name"
      t.string "file_file_name"
      t.string "file_content_type"
      t.integer "file_file_size"
      t.datetime "file_updated_at"
      t.string "file_fingerprint"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "datasets", id: :serial, force: :cascade do |t|
      t.string "name"
      t.integer "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean "fetch", default: false
      t.integer "document_count", default: 0
      t.index ["user_id"], name: "index_datasets_on_user_id"
    end
    create_table "datasets_file_results", id: :serial, force: :cascade do |t|
      t.integer "datasets_file_id"
      t.string "style"
      t.binary "file_contents"
    end
    create_table "datasets_files", id: :serial, force: :cascade do |t|
      t.string "description"
      t.string "short_description"
      t.integer "task_id"
      t.string "result_file_name"
      t.string "result_content_type"
      t.integer "result_file_size"
      t.datetime "result_updated_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "downloadable", default: false
    end
    create_table "datasets_queries", id: :serial, force: :cascade do |t|
      t.integer "dataset_id"
      t.string "q"
      t.string "fq"
      t.string "def_type"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "datasets_tasks", id: :serial, force: :cascade do |t|
      t.string "name"
      t.datetime "finished_at"
      t.integer "dataset_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean "failed", default: false
      t.string "job_type"
      t.float "progress"
      t.string "progress_message"
      t.datetime "last_progress"
      t.string "job_id"
      t.index ["dataset_id"], name: "index_datasets_tasks_on_dataset_id"
    end
    create_table "documents_categories", id: :serial, force: :cascade do |t|
      t.integer "parent_id"
      t.integer "sort_order"
      t.string "name"
      t.text "journals"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "documents_category_hierarchies", id: false, force: :cascade do |t|
      t.integer "ancestor_id", null: false
      t.integer "descendant_id", null: false
      t.integer "generations", null: false
      t.index ["ancestor_id", "descendant_id", "generations"], name: "documents_category_anc_desc_udx", unique: true
      t.index ["descendant_id"], name: "documents_category_desc_idx"
    end
    create_table "documents_stop_lists", id: :serial, force: :cascade do |t|
      t.string "language"
      t.text "list"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "que_jobs", primary_key: ["queue", "priority", "run_at", "job_id"], comment: "3", force: :cascade do |t|
      t.integer "priority", limit: 2, default: 100, null: false
      t.datetime "run_at", default: -> { "now()" }, null: false
      t.bigserial "job_id", null: false
      t.text "job_class", null: false
      t.json "args", default: [], null: false
      t.integer "error_count", default: 0, null: false
      t.text "last_error"
      t.text "queue", default: "", null: false
    end
    create_table "users", id: :serial, force: :cascade do |t|
      t.string "email", default: "", null: false
      t.string "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "language", default: "en"
      t.string "timezone", default: "Eastern Time (US & Canada)"
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer "sign_in_count", default: 0
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.string "current_sign_in_ip"
      t.string "last_sign_in_ip"
      t.integer "csl_style_id"
      t.boolean "workflow_active", default: false
      t.string "workflow_class"
      t.text "workflow_datasets", default: [], array: true
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    end
    create_table "users_csl_styles", id: :serial, force: :cascade do |t|
      t.string "name"
      t.text "style"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    create_table "users_libraries", id: :serial, force: :cascade do |t|
      t.string "name"
      t.string "url"
      t.integer "user_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["user_id"], name: "index_users_libraries_on_user_id"
    end
    add_foreign_key "datasets", "users", name: "datasets_user_id_fk", on_delete: :cascade
    add_foreign_key "datasets_tasks", "datasets", name: "datasets_analysis_tasks_dataset_id_fk"
    add_foreign_key "documents_categories", "documents_categories", column: "parent_id", name: "documents_categories_parent_id_fk"
    add_foreign_key "documents_category_hierarchies", "documents_categories", column: "ancestor_id", name: "documents_category_hierarchies_ancestor_id_fk"
    add_foreign_key "documents_category_hierarchies", "documents_categories", column: "descendant_id", name: "documents_category_hierarchies_descendant_id_fk"
    add_foreign_key "users_libraries", "users", name: "users_libraries_user_id_fk", on_delete: :cascade
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end
