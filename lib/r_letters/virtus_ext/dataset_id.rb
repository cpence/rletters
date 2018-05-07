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
          return GlobalID::Locator.locate(value) if value.start_with?('gid://')
          return Dataset.find(value)
        end

        raise ArgumentError, "cannot create dataset from #{value.class}"
      end
    end
  end
end
