# -*- encoding : utf-8 -*-
# :nocov:

if RUBY_PLATFORM == 'java'
  # On JRuby, Nokogiri requires that we prefix *every* attribute with 'xmlns:',
  # so that they are added using the "namespace-aware" Xerces functions.  On
  # MRI, on the other hand, "xmlns:"-prefixed attributes *explicitly* don't
  # work.  So monkey patch the prefix in right here on JRuby.
  module Nokogiri
    module XML
      class Node
        alias_method :old_bracket_equals, :[]=

        def []=(name, value)
          name = "xmlns:#{name}" unless name.include?(':')
          old_bracket_equals(name, value)
        end
      end
    end
  end
end
