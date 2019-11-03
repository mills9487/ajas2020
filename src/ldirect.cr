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

  def subdivide(dimension : UInt8)
    left = Hyperrectangle.new(@size.clone, @center.clone)
    right = Hyperrectangle.new(@size.clone, @center.clone)
    left.size[dimension] /= 3
    @size[dimension] /= 3
    right.size[dimension] /= 3
    left.center[dimension] -= 2 * left.size[dimension]
    right.center[dimension] -= 2 * right.size[dimension]
    {left, right}
  end
end

carol = Hyperrectangle.new([0.5, 0.5], [0.5, 0.5])
laryl, darryl = carol.subdivide(0)
puts laryl.center
puts carol.center
puts darryl.center
