# -*- encoding : utf-8 -*-

ActiveAdmin.register Admin::UploadedAsset do
  actions :index, :update, :edit, :show
  menu parent: 'admin_settings'
  filter :name

  index do
    column :friendly_name
    actions
  end

  show title: :friendly_name do |asset|
    attributes_table do
      row :id
      row :friendly_name
      if asset.file_content_type.start_with? 'image/'
        row :preview do
          image_tag asset.file
        end
      end
      row :filename do
        asset.file_file_name
      end
      row :size do
        I18n.t('admin.uploaded_asset.file_details',
               size: asset.file_file_size)
      end
      row :content_type do
        asset.file_content_type
      end
    end
  end

  form do |f|
    f.inputs I18n.t('admin.uploaded_asset.asset_header',
                    name: admin_uploaded_asset.friendly_name) do
      f.input :file
    end
    f.actions
  end

  # :nocov:
  controller do
    def permitted_params
      params.permit admin_uploaded_asset: [:name, :file]
    end
  end
  # :nocov:
end
