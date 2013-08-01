# -*- encoding : utf-8 -*-

class Hash

  # Return a copy of self, with self and all elements converted to plain hashes
  #
  # This function will recursively convert any HashWithIndifferentAccess classes
  # found in the hash to plain hashes.  It is thus the (equally recursive)
  # counterpart to Hash#with_indifferent_access.
  #
  # @return [Hash] hash without indifferent hashes
  def without_indifferent_access
    result = self.to_hash

    result.each do |key, value|
      case value
      when Hash
        result[key] = value.without_indifferent_access
      when Array
        result[key] = value.without_indifferent_access
      end
    end

    result
  end
end
