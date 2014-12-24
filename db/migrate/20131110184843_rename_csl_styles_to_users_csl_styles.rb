class RenameCslStylesToUsersCslStyles < ActiveRecord::Migration
  def change
    rename_table 'csl_styles', 'users_csl_styles'
  end
end
