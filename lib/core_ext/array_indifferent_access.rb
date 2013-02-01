# -*- encoding : utf-8 -*-
require Rails.root.join('lib', 'core_ext', 'hash_without_indifferent_access')

class Array
  # Return a copy of self with any hashes in the array converted to
  # HashWithIndifferentAccess.
  #
  # Note that we only have to ensure that this is done to the first layer of
  # array elements; Hash#with_indifferent_access will then work recursively
  # for any further layers.
  #
  # @return [Array] array with indifferent hashes
  def with_indifferent_access
    map do |value|
      case value
      when Hash
        value.with_indifferent_access
      when Array
        value.with_indifferent_access
      else
        value
      end
    end
  end
  
  # Return a copy of self with any HashWithIndifferentAccess in the array
  # converted to plain hashes.
  #
  # @return [Array] array without indifferent hashes
  def without_indifferent_access
    map do |value|
      case value
      when Hash
        value.without_indifferent_access
      when Array
        value.without_indifferent_access
      else
        value
      end
    end
  end
end
