# -*- encoding : utf-8 -*-

ActiveAdmin.register Admin::Administrator do
  menu parent: 'users'

  index do
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    actions
  end

  filter :email

  form do |f|
    f.inputs I18n.t('admin.administrator.admin_details') do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  # :nocov:
  controller do
    def permitted_params
      params.permit admin_administrator: [:email, :password, :password_confirmation]
    end
  end
  # :nocov:
end
