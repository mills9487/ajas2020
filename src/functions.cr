def six_hump_camel(x : Array(Float64)) : Float64
  # Six-Hump Camel function
  a = (x[0] * 6.0) - 3.0
  b = (x[1] * 4.0) - 2.0
  res = ((4 - 2.1*a**2 + a**4/3)*a**2 + a*b + (-4 + 4*b**2)*b**2)
  res += 1.0316
  res /= 81.93825
  res -= 1.0
  if res <= -1.0
    return -1.0
  elsif res >= 1.0
    return 1.0
  else
    return res
  end
end

def goldstein_price(x : Array(Float64)) : Float64
  a = x[0]
  b = x[1]
  res = (1 + (a + b + 1)**2 * (19 - 14*a + 3*a**2 - 14*b + 6*a*b + 3*b**2)) *
        (30 + (2*a - 3*b)**2 * (18 - 32*a + 12*a**2 + 48*b - 36*a*b + 27*b**2))
  # res -= 3.0
  # res /= 478298.9991
  # res -= 1.0
  # if res <= -1.0
  #   return -1.0
  # elsif res >= 1.0
  #   return 1.0
  # else
  #   return res
  # end
  res
end

def shubert(x : Array(Float64)) : Float64
  # Shubert function
  a = (x[0] * 20.0) - 10.0
  b = (x[1] * 20.0) - 10.0
  temp_1 = 0.0
  5.times do |i|
    temp_1 += (i + 1) * Math.cos((i + 2) * a + i + 1)
  end
  temp_2 = 0.0
  5.times do |i|
    temp_2 += (i + 1) * Math.cos((i + 2) * b + i + 1)
  end
  res = temp_1 * temp_2
  # res += 186.7309
  # res /= 198.6066
  # res -= 1.0
  # if res <= -1.0
  #   return -1.0
  # elsif res >= 1.0
  #   return 1.0
  # else
  #   return res
  # end
  res / 20.0
end

def hartmann_6(x : Array(Float64)) : Float64
  # 6-dimensional Hartmann function
  alpha = [1.0, 1.2, 3.0, 3.2]
  a = [[10.0, 3.0, 17.0, 3.5, 1.7, 8.0],
       [0.05, 10.0, 17.0, 0.1, 8.0, 14.0],
       [3.0, 3.5, 1.7, 10.0, 17.0, 8.0],
       [17.0, 8.0, 0.05, 10.0, 0.1, 14.0]]
  p = [[1312.0, 1696.0, 5569.0, 124.0, 8283.0, 5886.0],
       [2329.0, 4135.0, 8307.0, 3736.0, 1004.0, 9991.0],
       [2348.0, 1451.0, 3522.0, 2883.0, 3047.0, 6650.0],
       [4047.0, 8828.0, 8732.0, 5743.0, 1091.0, 381.0]]
  p.size.times do |row|
    p[row].size.times do |element|
      p[row][element] /= 10000.0
    end
  end

  res = 0.0
  4.times do |i|
    inner = 0
    6.times do |j|
      inner += a[i][j] * (x[j] - p[i][j])**2
    end
    res -= alpha[i] * Math.exp(-inner)
  end

  res
end
