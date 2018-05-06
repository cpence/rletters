# frozen_string_literal: true

module RLetters
  module VirtusExt
    # A class to encapsulate an attribute that can be passed as a space-separated
    # list
    class SplitList < Virtus::Attribute
      # Coerce the list into an array if it's a string
      #
      # This function can handle strings, nils, arrays, and a
      # `Documents::StopList` object.
      #
      # @param [Object] value the object to coerce
      # @return [Array] representation as an array
      def coerce(value)
        return nil if value.blank?
        return value if value.is_a?(Array)
        return value.list.split if value.is_a?(::Documents::StopList)
        return value.mb_chars.downcase.to_s.strip.split if value.is_a?(String)
        raise ArgumentError, "cannot create list from #{value.class}"
      end
    end
  end
end
