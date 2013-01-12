# -*- encoding : utf-8 -*-

ActiveAdmin.register Settings do
  actions :except => [ :index, :update, :edit, :show ]
  config.filters = false
  config.batch_actions = false
  
  controller do
    def index
      redirect_to list_admin_settings_path
    end
  end
  
  collection_action :list do
    @page_title = "All Settings"
    
    @settings_hash = Settings.defaults.merge(Settings.all)
    @settings = []
    @settings_hash.each { |k, v| @settings << Settings::Value.new(k.to_sym, v) }
  end

  action_item :only => :list do
    link_to("Edit", change_admin_settings_path)
  end
  
  collection_action :change do
    @page_title = "Edit Settings"
    
    @settings_hash = Settings.defaults.merge(Settings.all)
    @settings = []
    @settings_hash.each { |k, v| @settings << Settings::Value.new(k.to_sym, v) }
  end  
  
  collection_action :set_values, :method => :post do
    new_settings = params[:settings]
    new_settings.each do |k, v|
      # Only update things that aren't inheriting defaults
      if Settings.all.include? k
        Settings[k] = v
      elsif Settings.defaults[k] != v
        Settings[k] = v
      end
    end
    
    redirect_to admin_settings_path
  end
end
