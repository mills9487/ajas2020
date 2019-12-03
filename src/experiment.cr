require "./ldirect.cr"
require "./functions.cr"

# Runs the experiment from the original project
# Takes the Shubert, Six-Hump Camel, Goldstein-Price, Sixth-Dimensional
# Hartmann, Shekel, and Branin RCOS test functions and applies the lDIRECT
# algorithm to each, using 512 different values of H and eta (262,144 total).
# Then, saves the optimum found for each combination to that function's
# respective `.dat` file in CSV format.
def run_experiment
  final = [] of Array(Float64)
  percentage = 0.0
  color = 37

  print "\e[?25l"

  ["shubert", "six_hump_camel", "goldstein_price",
   "hartmann_6", "shekel", "branin_rcos"].each do |function|
    case function
    when "shubert"
      test_function = ->shubert(Array(Float64))
      dimensions = 2
    when "six_hump_camel"
      test_function = ->six_hump_camel(Array(Float64))
      dimensions = 2
    when "goldstein_price"
      test_function = ->goldstein_price(Array(Float64))
      dimensions = 2
    when "hartmann_6"
      test_function = ->hartmann_6(Array(Float64))
      dimensions = 6
    when "shekel"
      test_function = ->shekel(Array(Float64))
      dimensions = 4
    when "branin_rcos"
      test_function = ->branin_rcos(Array(Float64))
      dimensions = 2
    else
      raise Exception.new("What the hecc")
    end

    puts "#{function}:"
    512.times do |j|
      results = [] of Float64
      512.times do |i|
        printf "\e[38;5;%im%.2f%% complete ", color, percentage
        printf "\e[G"
        results.push(ldirect(Array.new(dimensions, 0.5),
          Array.new(dimensions, 0.5),
          0.0001, test_function,
          (i + 1)/512.0, (j + 1)/512.0))
        percentage = (((512 * j) + i) / 262144) * 100
        if percentage <= 60
          color = 196 + 6*(percentage // 10)
        else
          color = 226 - 36*(((percentage - 60) // 10) + 1)
        end
      end
      final.push(results)
    end

    output_file = File.new("#{function}.dat", mode = "w")

    final.each do |array|
      (array.size - 1).times do |index|
        output_file << array[index]
        output_file << ", "
      end
      output_file << array[-1]
      output_file << "\n"
    end

    output_file.close
    final.clear

    print "\e[KFinished!\a\n\e[0m"
  end
end

percentage = 0.0
color = 37

3.times do |i|
  case i
  when 0
    output_file = File.new("data/error_function.dat", mode = "w")
    quality_distribution = ->error_function(Float64, Float64, Float64)
    name = "Error Function (erf)"
  when 1
    output_file = File.new("data/logistic_function.dat", mode = "w")
    quality_distribution = ->logistic_function(Float64, Float64, Float64)
    name = "Logistic Function"
  when 2
    output_file = File.new("data/inverse_tangent.dat", mode = "w")
    quality_distribution = ->inverse_tangent(Float64, Float64, Float64)
    name = "Inverse Tangent (atan)"
  else
    raise Exception.new
  end

  print "\e[?25l"
  512.times do |j|
    64.times do |k|
      percentage = ((j * 64) + k) / 327.68
      if percentage <= 60
        color = 196 + 6*(percentage // 10)
      else
        color = 226 - 36*(((percentage - 60) // 10) + 1)
      end
      printf "\e[0m#{name}: "
      printf "\e[38;5;%im%.2f%% complete\e[K", color, percentage
      printf "\e[G"
      val = ldirect(Array.new(6, 0.5), Array.new(6, 0.5), 0.0001,
        ->hartmann_6(Array(Float64)), (j + 1) / 512.0,
        0.5, quality_distribution)
      output_file << (j + 1) / 512.0 << ", " << val << "\n"
    end
  end
  printf "\e[0m#{name}: \e[38;5;%imFinished!\e[K\n\a", color
  percentage = 0.0
  color = 37
  output_file.close
end
