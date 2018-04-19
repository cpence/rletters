# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_04_19_133902) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_markdown_pages", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_uploaded_assets", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "datasets", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "fetch", default: false
    t.integer "document_count", default: 0
    t.index ["user_id"], name: "index_datasets_on_user_id"
  end

  create_table "datasets_files", id: :serial, force: :cascade do |t|
    t.string "description"
    t.string "short_description"
    t.integer "task_id"
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
    t.string "name", limit: 255
    t.datetime "finished_at"
    t.integer "dataset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "failed", default: false
    t.string "job_type", limit: 255
    t.float "progress"
    t.string "progress_message"
    t.datetime "last_progress"
    t.string "job_id"
    t.index ["dataset_id"], name: "index_datasets_tasks_on_dataset_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "documents_categories", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "journals"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "ancestry"
    t.index ["ancestry"], name: "index_documents_categories_on_ancestry"
  end

  create_table "documents_stop_lists", id: :serial, force: :cascade do |t|
    t.string "language", limit: 255
    t.text "list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "language", limit: 255, default: "en"
    t.string "timezone", limit: 255, default: "Eastern Time (US & Canada)"
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.integer "csl_style_id"
    t.boolean "workflow_active", default: false
    t.string "workflow_class", limit: 255
    t.text "workflow_datasets", default: [], array: true
    t.string "export_archive_file_name"
    t.string "export_archive_content_type"
    t.integer "export_archive_file_size"
    t.datetime "export_archive_updated_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_csl_styles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "style"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users_libraries", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "url", limit: 255
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_users_libraries_on_user_id"
  end

  add_foreign_key "datasets", "users", name: "datasets_user_id_fk", on_delete: :cascade
  add_foreign_key "datasets_tasks", "datasets", name: "datasets_analysis_tasks_dataset_id_fk"
  add_foreign_key "users_libraries", "users", name: "users_libraries_user_id_fk", on_delete: :cascade
end
