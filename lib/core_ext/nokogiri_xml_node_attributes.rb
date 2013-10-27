# -*- encoding : utf-8 -*-

if RUBY_PLATFORM == 'java'

  # Nokogiri's XML node class
  class Nokogiri::XML::Node
    alias_method :old_bracket_equals, :[]=

    # On JRuby, Nokogiri requires that we prefix *every* attribute with
    # 'xmlns:', so that they are added using the "namespace-aware" Xerces
    # functions.  On MRI, on the other hand, "xmlns:"-prefixed attributes
    # *explicitly* don't work.  So monkey patch the prefix in right here
    # on JRuby.
    #
    # None of this would be a problem if Nokogiri worked *remotely* the same
    # on JRuby and MRI.  *sigh*
    def []=(name, value)
      name = "xmlns:#{name}" unless name.include?(':')
      old_bracket_equals(name, value)
    end
  end

end
