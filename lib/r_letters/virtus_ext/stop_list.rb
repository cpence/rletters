
module RLetters
  module VirtusExt
    # A class to coerce strings to stop lists, and then on to arrays of
    # strings
    class StopList < Virtus::Attribute
      # Coerce the list into an array if it's a string
      #
      # @param [Object] value the object to coerce
      # @return [Array] representation as an array
      def coerce(value)
        return nil if value.blank?
        return value.list.split if value.is_a?(::Documents::StopList)
        if value.is_a?(String)
          dsl = ::Documents::StopList.find_by(language: value)
          return dsl.list.split if dsl
          return value.mb_chars.downcase.to_s.strip.split
        end
        fail ArgumentError, "cannot create stop list from #{value.class}"
      end
    end
  end
end
