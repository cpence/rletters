# frozen_string_literal: true

# Ruby's base Numeric class
class Numeric
  # Return bound if self is less than bound
  #
  # @param [Numeric] bound lower bound for comparison
  # @return [Numeric] self if greater than bound, else bound
  def lbound(bound)
    self < bound ? bound : self
  end

  # Return bound if self is greater than bound
  #
  # @param [Numeric] bound upper bound for comparison
  # @return [Numeric] self if less than bound, else bound
  def ubound(bound)
    self > bound ? bound : self
  end

  # Clamp self by the given bounds (exclusive)
  #
  # @param [Numeric] min lower bound
  # @param [Numeric] max upper bound
  # @return [Numeric] self if within bounds, else one of the bounds
  def bound(min, max)
    if self < min
      min
    elsif self > max
      max
    else
      self
    end
  end
end
