# frozen_string_literal: true

class String
  # Return the value of this string as a boolean
  #
  # This simply delegates to the support provided by ActiveRecord.
  #
  # @return [Boolean] true, false, or nil (if string is nil)
  def to_boolean
    ActiveModel::Type::Boolean.new.cast(self)
  end
end
