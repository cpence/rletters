# -*- encoding : utf-8 -*-

# Ruby's base Numeric class
class Numeric
  # Return bound if self is less than bound
  #
  # @param [Numeric] bound lower bound for comparison
  # @return [Numeric] self if greater than bound, else bound
  # @example Ensure that val is greater than 0
  #   -3.lbound(0)
  #   # => 0
  #   5.lbound(0)
  #   # => 5
  def lbound(bound)
    self < bound ? bound : self
  end

  # Return bound if self is greater than bound
  #
  # @param [Numeric] bound upper bound for comparison
  # @return [Numeric] self if less than bound, else bound
  # @example Ensure that val is less than 10
  #   38.ubound(10)
  #   # => 10
  #   5.ubound(10)
  #   # => 5
  def ubound(bound)
    self > bound ? bound : self
  end

  # Clamp self by the given bounds (exclusive)
  #
  # @param [Numeric] min lower bound
  # @param [Numeric] max upper bound
  # @return [Numeric] self if within bounds, else one of the bounds
  # @example Ensure that val is between 5 and 10
  #   4.bound(5, 10)
  #   # => 5
  #   5.bound(5, 10)
  #   # => 5
  #   10.bound(5, 10)
  #   # => 10
  #   30.bound(5, 10)
  #   # => 10
  def bound(min, max)
    self < min ? min : (self > max ? max : self)
  end
end
