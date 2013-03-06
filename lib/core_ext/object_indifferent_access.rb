# -*- encoding : utf-8 -*-
require Rails.root.join('lib', 'core_ext', 'hash_without_indifferent_access')
require Rails.root.join('lib', 'core_ext', 'array_indifferent_access')

class Object
  # If this object is a Hash or an Array, convert any hashes to indifferent
  # access.
  #
  # @return [Object] object with indifferent hashes
  def with_indifferent_access
    if self.duplicable?
      return self.dup
    else
      return self
    end
  end
end
