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
    right.center[dimension] += 2 * right.size[dimension]
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
  stack = [] of Int32
  hyperrectangles.sort!
  index = 0
  hyperrectangles.each do |hr|
    while stack.size >= 1 && value.call(hyperrectangles[stack[-1]].center) >= value.call(hr.center)
      stack.pop
    end
    stack.push(index)
    hr.center_value = value.call(hr.center)
    index += 1
  end
  index = 0
  stack.each do |optimal|
    if index != stack.size - 1
      hyperrectangles[optimal].k_tilde = (value.call(hyperrectangles[optimal].center) -
                                          value.call(hyperrectangles[stack[index - 1]].center)) /
                                         (hyperrectangles[optimal].radius -
                                          hyperrectangles[stack[index - 1]].radius)
    end
  end
  stack
end

carol = Hyperrectangle.new([0.5, 0.5], [0.5, 0.5])
laryl, darryl = carol.subdivide(0)
puts laryl.center
puts carol.center
puts darryl.center

phil, chil = laryl.subdivide(1)

def test(x : Array(Float64))
  x[0]**2 * x[1]**2
end

darryl.size[0] = 0

puts get_optimal_hyperrectangles([laryl, carol, darryl, phil, chil], ->test(Array(Float64)), 0)
