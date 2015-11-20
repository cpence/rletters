
ActiveAdmin.register Documents::StopList do
  actions :index, :update, :edit, :show
  menu parent: 'Settings'

  filter :name
  config.batch_actions = false

  permit_params :language, :list

  index do
    column :display_language
    actions
  end

  show title: :display_language do
    attributes_table do
      row :id
      row :language
      row :display_language
      row :list
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs I18n.t('admin.stop_list.header',
                    language: documents_stop_list.display_language) do
      f.input :list, input_html: { rows: 30 }
    end
    f.actions
  end
end
