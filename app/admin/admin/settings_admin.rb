# -*- encoding : utf-8 -*-

ActiveAdmin.register Admin::Setting do
  actions :index, :update, :edit
  config.filters = false
  config.batch_actions = false

  controller do
    def scoped_collection
      # Force copies of all the settings into the database, if we have to, so
      # that ActiveAdmin has something to work with
      Admin::Setting.valid_keys.each do |k|
        Admin::Setting.where(key: k).first_or_create(value: Admin::Setting.send(k))
      end

      # Don't show the hidden settings
      Admin::Setting.where.not(key: Admin::Setting.hidden_keys)
    end
  end

  index do
    column :friendly_name
    column :value
    default_actions
  end

  form do |f|
    f.inputs "Setting: #{admin_setting.friendly_name}" do
      f.input :value
    end
    f.actions
  end

  # :nocov:
  controller do
    def permitted_params
      params.permit admin_setting: [:key, :value]
    end
  end
  # :nocov:
end
