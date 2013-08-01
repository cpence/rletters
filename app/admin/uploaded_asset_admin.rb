# -*- encoding : utf-8 -*-

ActiveAdmin.register UploadedAsset do
  actions :index, :update, :edit, :show
  menu :parent => "Settings"
  filter :name

  index do
    column :friendly_name
    default_actions
  end

  show :title => :friendly_name do |asset|
    attributes_table do
      row :id
      row :friendly_name
      if asset.file_content_type.start_with? "image/"
        row :preview do
          image_tag asset.file
        end
      end
      row :filename do
        asset.file_file_name
      end
      row :size do
        if asset.file.width && asset.file.height
          "#{asset.file.width}x#{asset.file.height} (#{asset.file_file_size} bytes)"
        else
          "#{asset.file_file_size} bytes"
        end
      end
      row :content_type do
        asset.file_content_type
      end
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Asset: #{uploaded_asset.friendly_name}" do
      f.input :file
    end
    f.buttons
  end
end
