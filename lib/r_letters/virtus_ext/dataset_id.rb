# frozen_string_literal: true

module RLetters
  module VirtusExt
    # A class to encapsulate a dataset ID, which may need to be looked up from
    # a string
    class DatasetID < Virtus::Attribute
      # Coerce the ID to a Dataset
      #
      # @param [Object] value the object to coerce
      # @return [Dataset] dataset
      def coerce(value)
        return nil if value.blank?
        return value if value.is_a?(Dataset)

        if value.is_a?(String)
          if value.start_with?('gid://')
            return GlobalID::Locator.locate(value)
          else
            return Dataset.find(value)
          end
        end

        fail ArgumentError, "cannot create dataset from #{value.class}"
      end
    end
  end
end
