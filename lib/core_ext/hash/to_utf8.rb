
# Ruby's base object class
class Object
  # Define a no-op to_utf8! method on all objects
  #
  # This enables easy recursion for Hash#to_utf8!.
  #
  # @return [self]
  def to_utf8!
    self
  end
end

# Ruby's standard string class
class String
  # Convert this string to UTF-8
  #
  # @return [self]
  def to_utf8!
    force_encoding(Encoding::UTF_8)
  end
end

# Ruby's standard array class
class Array
  # Convert all string encodings in this array to UTF-8
  #
  # @return [self]
  def to_utf8!
    map!(&:to_utf8!)
  end
end

# Ruby's standard Hash class
class Hash
  # Set all string encodings in the hash to UTF-8
  #
  # Walks through self, recursively (including Hashes and Arrays), setting any
  # String values' encodings to UTF-8.
  #
  # @return [self]
  def to_utf8!
    each do |k, v|
      v.to_utf8!
      self[k] = v
    end
    self
  end
end
