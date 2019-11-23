class Hyperrectangle
  property size
  property center
  property k_tilde
  property center_value

  def initialize(size : Array(Float32), center : Array(Float32))
    @size = size
    @center = center
    @k_tilde = Float32::NAN
    @center_value = Float32::NAN
  end

  def radius
    result = 0_f32
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
        value : Proc(Array(Float32), Float32))
  (value.call(q.center) - value.call(p.center)) * (r.radius - q.radius) -
    (q.radius - p.radius) * (value.call(r.center) - value.call(q.center))
end

def get_optimal_hyperrectangles(hyperrectangles : Array(Hyperrectangle),
                                value : Proc(Array(Float32), Float32),
                                h : Float32)
  stack = [] of Int32
  hyperrectangles.sort!
  index = 0
  hyperrectangles.each do |hr|
    while stack.size >= 2 && ccw(hyperrectangles[stack[-1]], hyperrectangles[stack[-2]], hr, value) <= 0
      stack.pop
    end
    stack.push(index)
    hr.center_value = value.call(hr.center)
    index += 1
  end
  index = 0
  stack.each do |hr|
    if index > 0 && hyperrectangles[stack[0]].center_value > hyperrectangles[hr].center_value
      stack.delete_at(0)
    end
    index += 1
  end
  index = 0
  stack.each do |optimal|
    if index != stack.size - 1
      hyperrectangles[optimal].k_tilde = (value.call(hyperrectangles[optimal].center) -
                                          value.call(hyperrectangles[stack[index - 1]].center)) /
                                         (hyperrectangles[optimal].radius -
                                          hyperrectangles[stack[index - 1]].radius)
    else
      hyperrectangles[optimal].k_tilde = h
    end
    index += 1
  end
  stack
end

def test(x : Array(Float32)) : Float32
  # Six-hump camel back function
  (4_f32 - 2.1_f32*x[0]**2_f32 + x[0]**4_f32/3_f32)*x[0]**2_f32 + x[0]*x[1] + (-4_f32 + 4_f32*x[1]**2_f32)*x[1]**2_f32
end

puts ("First vanilla DIRECT test results:")

hr_list = [] of Hyperrectangle
start = Hyperrectangle.new([1_f32, 1_f32], [0_f32, 0_f32])
hr_list.push(start)

cur = 0_u8

optimals = get_optimal_hyperrectangles(hr_list, ->test(Array(Float32)), 0_f32)

50.times do
  optimals.each do |index|
    left, right = hr_list[index].subdivide(cur)
    hr_list.push(left)
    hr_list.push(right)
    if cur == 0_u8
      cur = 1_u8
    else
      cur = 0_u8
    end
  end
  optimals = get_optimal_hyperrectangles(hr_list, ->test(Array(Float32)), 0_f32)
end

optimals.each do |index|
  puts hr_list[index].k_tilde
end
