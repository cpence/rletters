# frozen_string_literal: true

class AddLanguageToSnippets < ActiveRecord::Migration[5.2]
  def up
    add_column :admin_snippets, :language, :string
    ActiveRecord::Base.connection.execute "UPDATE admin_snippets SET language = #{ActiveRecord::Base.connection.quote(:en)}"
  end

  def down
    remove_column :admin_snippets, :language
  end
end
