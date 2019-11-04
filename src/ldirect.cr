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

  def radius
    result = 0_f64
    size.each do |axis|
      result += axis**2
    end
    Math.sqrt(result)
  end

  def <=>(other : Hyperrectangle)
    self.radius - other.radius
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

def ccw(p : Hyperrectangle, q : Hyperrectangle, r : Hyperrectangle,
        value : Proc(Array(Float64), Float64))
  (value.call(q.center) - value.call(p.center)) * (r.radius - q.radius) -
    (q.radius - p.radius) * (value.call(r.center) - value.call(q.center))
end

def get_optimal_hyperrectangles(hyperrectangles : Array(Hyperrectangle),
                                value : Proc(Array(Float64), Float64),
                                h : Float64)
  stack = [] of UInt32
  hyperrectangles.sort!
  hyperrectangles.size.times do |index|
    while stack.size > 1 && ccw(hyperrectangles[stack[-2, 1]],
            hyperrectangles[stack[-1, 1]], hyperrectangle,
            value)
      stack.pop
    end
    stack.push(index)
  end
  stack.size.times do |index|
    if index != 0 && value.call(hyperrectangles[stack[index - 1]].radius) >=
         value.call(hyperrectangles[stack[index]].radius)
      stack.delete_at(index - 1)
    end
  end
  stack
end

carol = Hyperrectangle.new([0.5, 0.5], [0.5, 0.5])
laryl, darryl = carol.subdivide(0)
puts laryl.center
puts carol.center
puts darryl.center
