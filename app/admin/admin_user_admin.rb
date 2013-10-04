# -*- encoding : utf-8 -*-

ActiveAdmin.register AdminUser do
  menu parent: 'users'

  index do
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    default_actions
  end

  filter :email

  form do |f|
    f.inputs I18n.t('admin.admin_user.admin_details') do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  # :nocov:
  controller do
    def permitted_params
      params.permit admin_user: [:email, :password, :password_confirmation]
    end
  end
  # :nocov:
end
