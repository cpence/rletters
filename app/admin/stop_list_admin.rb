# -*- encoding : utf-8 -*-

ActiveAdmin.register Documents::StopList do
  actions :index, :update, :edit, :show
  menu parent: 'settings'
  filter :name

  index do
    column :display_language
    default_actions
  end

  show title: :display_language do |list|
    attributes_table do
      row :id
      row :language
      row :display_language
      row :list
    end
  end

  form do |f|
    f.inputs I18n.t('admin.stop_list.header',
                    language: documents_stop_list.display_language) do
      f.input :list, input_html: { rows: 30 }
    end
    f.actions
  end

  # :nocov:
  controller do
    def permitted_params
      params.permit documents_stop_list: [:language, :list]
    end
  end
  # :nocov:
end
