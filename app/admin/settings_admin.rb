# -*- encoding : utf-8 -*-

ActiveAdmin.register Setting do
  actions :index, :update, :edit
  config.filters = false
  config.batch_actions = false

  controller do
    def scoped_collection
      # Force copies of all the settings into the database, if we have to, so
      # that ActiveAdmin has something to work with
      Setting.valid_keys.each do |k|
        Setting.where(:key => k).first_or_create(:value => Setting.send(k))
      end

      p Setting.all
      Setting.all
    end
  end

  index do
    column :friendly_name
    column :value
    default_actions
  end

  form do |f|
    f.inputs "Setting: #{setting.friendly_name}" do
      f.input :value
    end
    f.buttons
  end
end
