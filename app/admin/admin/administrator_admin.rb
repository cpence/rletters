
ActiveAdmin.register Admin::Administrator do
  menu parent: 'users'

  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    actions
  end

  filter :email

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs I18n.t('admin.administrator.admin_details') do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
