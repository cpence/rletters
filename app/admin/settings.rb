# -*- encoding : utf-8 -*-

class SettingValue < Struct.new(:key, :val)
  include ActiveModel::Conversion  
  extend ActiveModel::Naming
    
  def persisted?; false; end
end

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
    @page_title = "Settings"
    
    @settings_hash = Settings.defaults.merge(Settings.all)
    @settings = []
    @settings_hash.each { |k, v| @settings << SettingValue.new(k.to_sym, v) }
  end
  
  #collection_action :set_value, :method => :post do
  #  redirect_to {:action => :index}, :notice => "got the redirect"
  #end
end