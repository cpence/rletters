# -*- encoding : utf-8 -*-
require 'active_record/base'

if RUBY_PLATFORM == 'java'

  # Rails' ActiveRecord module
  module ActiveRecord

    # The base class for all ActiveRecord models
    class Base
      # This fails for Absolutely No Reason(tm) on JRuby 1.7.4.  You can
      # actually see that ActiveRecord::Base.class_variable_get(:@@logger) is
      # valid, but then ActiveRecord::Base.logger still returns nil.
      # Monkey-patch it here.
      def self.logger
        Rails.logger
      end
    end

  end

end
