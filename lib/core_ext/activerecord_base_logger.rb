# -*- encoding : utf-8 -*-
require 'active_record/base'

# This fails for Absolutely No Reason(tm) on JRuby 1.7.4.  You can actually see
# that ActiveRecord::Base.class_variable_get(:@@logger) is valid, but then
# ActiveRecord::Base.logger still returns nil.  Monkey-patch it here.
module ActiveRecord
  class Base
    def self.logger
      Rails.logger
    end
  end
end
