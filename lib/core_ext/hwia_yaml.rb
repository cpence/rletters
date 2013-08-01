# -*- encoding : utf-8 -*-
require Rails.root.join('lib', 'core_ext', 'hash_without_indifferent_access')
require Rails.root.join('lib', 'core_ext', 'array_indifferent_access')

class HashWithIndifferentAccess
  # Convert from HashWithIndifferentAccess to plain hash and write to YAML
  #
  # @param [Hash] opts options, see Psych.dump
  # @return [String] YAML representation of self as a plain hash
  def to_yaml(opts = {})
    self.without_indifferent_access.to_yaml(opts)
  end
end

class Array
  alias_method :old_to_yaml, :to_yaml

  # Convert any HashWithIndifferentAccess elements to plain hash and write to
  # YAML
  #
  # @param [Hash] opts options, see Psych.dump
  # @return [String] YAML representation of self, with all plain hash elements
  def to_yaml(opts = {})
    # Psych will sometimes recursively call to_yaml from old_to_yaml; don't
    # get caught in an infinite loop
    file, line, meth = *caller(1).first.split(':')
    return if file =~ /\/psych\//

    self.without_indifferent_access.old_to_yaml(opts)
  end
end
