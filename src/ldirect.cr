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
                                h : Float64, current_best : Float64, epsilon : Float64)
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
    if index > 0 && hyperrectangles[stack[0]].center_value >= hyperrectangles[hr].center_value
      stack.delete_at(0)
    end
    index += 1
  end
  while stack.size >= 2 && hyperrectangles[stack[-1]].radius == hyperrectangles[stack[-2]].radius
    stack.pop
  end
  index = 0
  stack.each do |optimal|
    if index != stack.size - 1
      hyperrectangles[optimal].k_tilde = (value.call(hyperrectangles[optimal].center) -
                                          value.call(hyperrectangles[stack[index + 1]].center)) /
                                         (hyperrectangles[optimal].radius -
                                          hyperrectangles[stack[index + 1]].radius)
    else
      hyperrectangles[optimal].k_tilde = h
    end
    index += 1
  end
  index = 0
  if epsilon != 0
    stack.each do |optimal|
      if hyperrectangles[optimal].center_value - (hyperrectangles[optimal].k_tilde * hyperrectangles[optimal].radius) >=
           (1 + (current_best <= 0 ? 1 : -1) * epsilon) * current_best
        stack.delete_at(index)
      else
        index += 1
      end
    end
  end
  stack
end

def test(x : Array(Float64)) : Float64
  # Six-hump camel back function
  (4_f64 - 2.1_f64*x[0]**2_f64 + x[0]**4_f64/3_f64)*x[0]**2_f64 + x[0]*x[1] + (-4_f64 + 4_f64*x[1]**2_f64)*x[1]**2_f64
end

def shubert(x : Array(Float64)) : Float64
  # Shubert function
  temp_1 = 0
  5.times do |i|
    temp_1 += (i + 1) * Math.cos((i + 2) * x[0] + i + 1)
  end
  temp_2 = 0
  5.times do |i|
    temp_2 += (i + 1) * Math.cos((i + 2) * x[1] + i + 1)
  end
  (temp_1 * temp_2).as(Float64)
end

puts ("First vanilla DIRECT test results:")

hr_list = [] of Hyperrectangle
start = Hyperrectangle.new([5.12, 5.12], [0_f64, 0_f64])
hr_list.push(start)

cur = 0_u8

optimals = get_optimal_hyperrectangles(hr_list, ->shubert(Array(Float64)), 1_f64, -1.0 / 0.0, 0)

current_best = hr_list[optimals[0]].center_value

1000.times do |iteration|
  optimals.each do |index|
    left, right = hr_list[index].subdivide((hr_list[index].size.index(hr_list[index].size.max)).as(Int32).to_u8)
    hr_list.push(left)
    hr_list.push(right)
    if cur == 0_u8
      cur = 1_u8
    else
      cur = 0_u8
    end
  end
  optimals = get_optimal_hyperrectangles(hr_list, ->shubert(Array(Float64)), 1_f64, current_best, 0.00001)
  current_best = hr_list[optimals[0]].center_value
end

puts current_best
