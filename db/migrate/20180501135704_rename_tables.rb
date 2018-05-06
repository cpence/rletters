# frozen_string_literal: true
class RenameTables < ActiveRecord::Migration[5.2]
  def change
    rename_table :admin_uploaded_assets, :admin_assets
    rename_table :admin_markdown_pages, :admin_snippets
  end
end
