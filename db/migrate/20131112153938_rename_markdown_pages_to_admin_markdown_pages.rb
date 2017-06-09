class RenameMarkdownPagesToAdminMarkdownPages < ActiveRecord::Migration[4.2]
  def change
    rename_table 'markdown_pages', 'admin_markdown_pages'
  end
end
