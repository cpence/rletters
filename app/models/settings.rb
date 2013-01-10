# -*- encoding : utf-8 -*-
class Settings < RailsSettings::CachedSettings
	attr_accessible :var

  class Value < Struct.new(:key, :val)
    include ActiveModel::Conversion  
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    
    def persisted?; false; end
  end
end
