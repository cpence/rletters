# -*- encoding : utf-8 -*-
class RenameMarkdownPagesToAdminMarkdownPages < ActiveRecord::Migration
  def change
    rename_table 'markdown_pages', 'admin_markdown_pages'
  end
end
