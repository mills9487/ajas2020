# Implements the hyperrectangles used in the lDIRECT algorithm
# Acts as a useful helper class to encapsulate a hyperrectangle, allowing for
# much more readable and understandable code.
class Hyperrectangle
  property size
  property center
  property k_tilde
  property center_value

  def initialize(size : Array(Float64), center : Array(Float64))
    @size = size
    @center = center
    @k_tilde = Float64::NAN
    @center_value = Float64::NAN
  end

  def min
    @center_value - (@k_tilde * self.radius)
  end

  def radius
    result = 0_f64
    size.each do |axis|
      result += axis**2
    end
    Math.sqrt(result)
  end

  def ==(other : Hyperrectangle)
    self.radius == other.radius && self.center_value == other.center_value
  end

  def <=>(other : Hyperrectangle)
    if self.radius == other.radius
      self.center_value - other.center_value
    else
      self.radius - other.radius
    end
  end

  def subdivide
    dimension = size.index(size.max).as(Int32)
    left = Hyperrectangle.new(@size.clone, @center.clone)
    right = Hyperrectangle.new(@size.clone, @center.clone)
    left.size[dimension] /= 3
    @size[dimension] /= 3
    right.size[dimension] /= 3
    left.center[dimension] -= 2 * left.size[dimension]
    right.center[dimension] += 2 * right.size[dimension]
    {left, right}
  end
end
