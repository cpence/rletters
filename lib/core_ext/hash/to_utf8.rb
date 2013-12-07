# -*- encoding : utf-8 -*-

# Ruby's standard Hash class
class Hash

  # Set all string encodings in the hash to UTF-8
  #
  # Walks through self, recursively (including Hashes and Arrays), setting any
  # String values' encodings to UTF-8.
  #
  # @return [Hash] self
  def to_utf8!
    force_hash_to_utf8(self)
    self
  end

  private

  # Walk through a hash, setting any found string values to UTF-8
  #
  # @api private
  # @return [undefined]
  def force_hash_to_utf8(h)
    h.each do |k, v|
      if v.is_a? String
        v.force_encoding(Encoding::UTF_8)
      elsif v.is_a? Hash
        force_hash_to_utf8(v)
      elsif v.is_a? Array
        force_array_to_utf8(v)
      end
    end
  end

  # Walk through an array, setting any found string values to UTF-8
  #
  # @api private
  # @return [undefined]
  def force_array_to_utf8(a)
    a.each do |v|
      if v.is_a? String
        v.force_encoding(Encoding::UTF_8)
      elsif v.is_a? Hash
        force_hash_to_utf8(v)
      elsif v.is_a? Array
        force_array_to_utf8(v)
      end
    end
  end
end
