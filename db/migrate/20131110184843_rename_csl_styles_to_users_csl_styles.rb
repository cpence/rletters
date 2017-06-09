class RenameCslStylesToUsersCslStyles < ActiveRecord::Migration[4.2]
  def change
    rename_table 'csl_styles', 'users_csl_styles'
  end
end
