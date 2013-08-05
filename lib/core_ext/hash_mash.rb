# -*- encoding : utf-8 -*-

# Ruby's standard Hash class
class Hash
  # Convert to a HashWithIndifferentAccess.
  #
  # This method is used internally by RSolr::Ext, and needs to be overridden
  # here for our YAML serialization tricks to work.
  #
  # @return [HashWithIndifferentAccess] self with indifferent access
  def to_mash
    with_indifferent_access
  end
end

# Redefine the Mash class and replace it with HashWithIndifferentAccess
Object.send(:remove_const, :Mash) if Object.constants.include?(:Mash)
Mash = HashWithIndifferentAccess
