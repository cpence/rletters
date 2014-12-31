
# Ruby's standard Hash class
class Hash
  # Clean up a hash for use as a list of options
  #
  # When we have a one-shot list of options to pass to a job, there are
  # standard cleanups that need to be done to them.  We symbolize the keys,
  # strip all string values, remove any that are blank, and also remove
  # any nils.
  #
  # @return [self]
  def clean_options!
    symbolize_keys!
    each do |k, v|
      if v.is_a? String
        self[k] = v.strip
        delete(k) if self[k].empty?
      end
    end
    compact!
  end
end
