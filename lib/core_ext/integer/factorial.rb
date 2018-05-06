# frozen_string_literal: true

# Ruby's standard integer class
class Integer
  # Compute the factorial of the given integer
  #
  # @return [Integer] the factorial of this integer
  def factorial
    (1..self).reduce(:*) || 1
  end
end
