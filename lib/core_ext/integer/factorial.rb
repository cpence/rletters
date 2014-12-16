# -*- encoding : utf-8 -*-

# Ruby's standard integer class
class Integer
  # Compute the factorial of the given integer
  #
  # @api public
  # @return [Integer] the factorial of this integer
  # @example Compute the factorial of 4
  #   4.factorial
  #   # => 24
  def factorial
    (1..self).reduce(:*) || 1
  end
end
