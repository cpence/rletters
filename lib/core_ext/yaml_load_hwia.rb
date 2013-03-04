# -*- encoding : utf-8 -*-

module YAML
  class << self    
    alias_method :old_safe_load, :safe_load
    
    # Load a block of YAML, converting any hashes to HashWithIndifferentAccess
    #
    # This method will automatically and recursively scan any Array or Hash
    # elements, and convert any hashes found to indifferent access.
    #
    # @param arguments parameters to pass to the original YAML.safe_load
    # @return YAML serialized object, with converted hashes
    def safe_load(*arguments)
      result = old_safe_load(*arguments)
      
      case result
      when Hash
        result = result.with_indifferent_access
      when Array
        result = result.with_indifferent_access
      end

      result
    end
  end
end
