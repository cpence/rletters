
module RLetters
  # A class to encapsulate a string that should be lowercased when coerced
  class LowercaseString < Virtus::Attribute
    # Coerce the string to lowercase
    #
    # @param [Object] value the object to coerce
    # @return [String] lowercase string
    def coerce(value)
      return nil if value.nil?
      return value.mb_chars.downcase.to_s if value.is_a?(String)
      fail ArgumentError, "cannot create lowercase string from #{value.class}"
    end
  end
end
