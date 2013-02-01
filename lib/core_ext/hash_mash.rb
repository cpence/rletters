# -*- encoding : utf-8 -*-

class Hash
  # Convert to a HashWithIndifferentAccess.
  #
  # This method is used internally by RSolr::Ext, and needs to be overridden
  # here for our YAML serialization tricks to work.
  #
  # @return [HashWithIndifferentAccess] self with indifferent access
  def to_mash
    self.with_indifferent_access
  end
end

# Redefine the Mash class and replace it with HashWithIndifferentAccess
if Object.constants.include?(:Mash)
  Object.send(:remove_const, :Mash)
end
Mash = HashWithIndifferentAccess
