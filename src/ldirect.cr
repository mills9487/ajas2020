require "./hyperrectangle.cr"

# Determines the 'direction' of three `Hyperrectangles`
# If the three make a clockwise turn, returns `:clockwise`;
# if they make a counterclockwise turn, returns `:counterclockwise`;
# finally, if they are collinear, returns `:collinear`.
# Fairly self-explanatory, just put here as a helper for the Graham scan.
def turn(p : Hyperrectangle, q : Hyperrectangle, r : Hyperrectangle,
         value : Proc(Array(Float64), Float64))
  direction = (q.radius - p.radius) * (r.center_value - p.center_value) -
              (r.radius - p.radius) * (q.center_value - p.center_value)
  if direction < 0
    return :clockwise
  elsif direction > 0
    return :counterclockwise
  else
    return :collinear
  end
end

# Finds and returns the optimal hyperrectangles from an array
# Given an array of hyperrectangles, i.e. `hr_list`, uses the Graham scan
# algorithm to determine which hyperrectangles are optimal.
# **NOTE:**
# This primarily works because Crystal is pass-by-reference for classes,
# meaning that the hyperrectangles in the final array are directly connected
# to the hyperrectangles in the initial array. If this behavior ever changes,
# then this function will fail.
def get_optimal_hyperrectangles(hr_list : Array(Hyperrectangle),
                                epsilon : Float64, h : Float64,
                                value : Proc(Array(Float64), Float64),
                                current_best : Float64)
  stack = [] of Hyperrectangle
  hr_list.sort!

  # Determines the center values of each hyperrectangle now, save time
  hr_list.each do |hr|
    if hr.center_value.nan?
      # Reading this next bit feels like a tautology
      hr.center_value = value.call(hr.center)
    end
  end

  hr_list.uniq! { |s| s.radius * s.center_value }

  # Gets rid of degenerates before the intensive stuff (would add an extra
  # case for two hyperrectangles in here, but due to the way they're
  # subdivided, that sort of thing can't really happen)
  if hr_list.size == 1
    stack.push(hr_list[0])
    hr_list[0].k_tilde = h
    return stack
  end

  # Graham scan; this version only finds the lower convex hull, since that's
  # all that we will end up needing
  hr_list.each do |hr|
    hr.center_value = value.call(hr.center)
    while stack.size >= 2 &&
          turn(stack[-2], stack[-1], hr, value) != :counterclockwise
      stack.pop
    end
    stack.push(hr)
  end

  # Removes the downwards-sloping left lower convex hull, since we need
  # specifically the right side
  while stack.size >= 2 && stack[0].center_value >= stack[1].center_value
    stack.delete_at(0)
  end

  # Fix the issue where the very last two points are often collinear in a
  # vertical line, only preserve the lower one
  if stack.size >= 2 && stack[-1].radius == stack[-2].radius
    stack.pop
  end

  # Calculate and insert K-tilde values for each remaining optimal
  # hyperrectangle in the stack
  index = 0
  stack.each do |op|
    if op != stack[-1]
      op.k_tilde = (stack[index + 1].center_value - op.center_value) /
                   (stack[index + 1].radius - op.radius)
    else
      op.k_tilde = h
    end
    index += 1
  end

  # Implements the epsilon rule laid out in the original DIRECT paper
  # If one of these turns out not to be able to improve much on the current
  # best solution, delete it and recalculate K-tilde values accordingly
  index = 0
  stack.each do |op|
    if op.min >= (current_best - epsilon * current_best.abs)
      stack.delete_at(index)
    end
    index += 1
  end

  stack
end

# CDF of the normal distribution
# Used for the non-deterministic portion of the stopping conditions checker,
# and *technically* not the actual CDF because it's been adapted so that
# when x = 0, the output is 1.
def normal_cdf(x : Float64, y : Float64, sigma : Float64)
  1 + Math.erf((x - y) / (-sigma * Math.sqrt(2)))
end

def hyperbolic_tangent(x : Float64, y : Float64, sigma : Float64)
  1 - Math.tanh((x - y) / sigma)
end

def error_function(x : Float64, y : Float64, sigma : Float64)
  1 - Math.erf((x - y) / sigma)
end

def logistic_function(x : Float64, y : Float64, sigma : Float64)
  2 / (1 + Math.exp((x - y) / sigma))
end

def inverse_tangent(x : Float64, y : Float64, sigma : Float64)
  1 - (Math.atan((x - y) / sigma) * (2.0 / Math::PI))
end

# Implements the lDIRECT algorithm
# Uses a quality-based stopping criterion with the DIRECT algorithm.
def ldirect(size : Array(Float64), center : Array(Float64), epsilon : Float64,
            test_function : Proc(Array(Float64), Float64), sigma : Float64,
            h : Float64, qd : Proc(Float64, Float64, Float64, Float64))
  start = Hyperrectangle.new(size, center)
  hr_list = [start]
  current_best = test_function.call(center)
  optimals = [] of Hyperrectangle
  begin_time = Time.utc

  while true
    optimals = get_optimal_hyperrectangles(hr_list, epsilon, h, test_function,
      current_best)

    if optimals[0].center_value < current_best
      current_best = optimals[0].center_value
    end

    minima = Array.new(optimals.size) { |i| optimals[i].min }

    # King of kings, Lord of lords
    # Minimum of minima
    absolute_minimum = minima.min
    will_accept = qd.call(current_best, absolute_minimum, sigma)
    the_arbitrator = Random::Secure.rand
    if the_arbitrator <= will_accept || (Time.utc - begin_time) >= 10.seconds
      break
    end

    optimals.each do |op|
      left, right = op.subdivide
      hr_list.push(left)
      hr_list.push(right)
    end
  end

  current_best
end
