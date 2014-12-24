
# Ruby's base String class
class String
  # Return the value of this string, suitable for use as an HTML ID
  #
  # HTML IDs must begin with an alphanumeric character, and can only contain
  # [A-Za-z0-9\-_]. Characters outside that range are substituted to
  # underscore.
  #
  # @return [String] a new String suitable for use as an HTML ID
  def html_id
    gsub(/[^0-9a-zA-Z\-_]/, '_').tap do |ret|
      ret.prepend('a') if ret[0] !~ /[a-zA-Z]/
    end
  end

  # Make this string suitable for use as an HTML ID
  #
  # HTML IDs must begin with an alphanumeric character, and can only contain
  # [A-Za-z0-9\-_]. Characters outside that range are substituted to
  # underscore.
  #
  # @return [self]
  def html_id!
    gsub!(/[^0-9a-zA-Z\-_]/, '_')
    prepend('a') if self[0] !~ /[a-zA-Z]/
    self
  end
end
