# frozen_string_literal: true

module RLetters
  module VirtusExt
    # A class to coerce strings to stop lists
    class StopList < Virtus::Attribute
      # Coerce the list into an array if it's a string
      #
      # @param [Object] value the object to coerce
      # @return [Array] representation as an array
      def coerce(value)
        return nil if value.blank?
        return value if value.is_a?(Array)
        if value.is_a?(String)
          list = RLetters::Analysis::StopList.for(value.to_sym)
          return list if list.present?

          # Treat the string as a space-separated list
          return value.mb_chars.downcase.to_s.strip.split
        end
        raise ArgumentError, "cannot create stop list from #{value.class}"
      end
    end
  end
end
