def import_from_file(filename)
  file = File.open(filename)
  file.read
end

TEST_INPUT = <<~INPUT
  Time:      7  15   30
  Distance:  9  40  200
INPUT

REAL_INPUT = import_from_file('day06_input.txt')

def part_one(input)
  time_line, dist_line = input.split("\n")
  times = time_line.split(':')[1].lstrip.split(' ').map(&:to_i)
  distances = dist_line.split(':')[1].lstrip.split(' ').map(&:to_i)
  (0...times.length).map do |i|
    total = 0
    time = times[i]
    (1...time).each do |j|
      total += 1 if j * (time - j) > distances[i]
    end
    total
  end.inject(&:*)
end

def part_two(input)
  time_line, dist_line = input.split("\n")
  time = time_line.delete(' ').split(':')[1].to_i
  distance = dist_line.delete(' ').split(':')[1].to_i

  # binary search for low end of range
  low = time / 2
  low_min = 0
  low_max = time
  loop do
    if low * (time - low) > distance
      low_max = low
      low = (low + low_min) / 2
    elsif (low + 1) * (time - low - 1) < distance
      low_min = low
      low = (low + low_max) / 2
    else
      break
    end
  end

  # binary search for high end of range
  high = time / 2
  high_min = low
  high_max = time
  loop do
    if high * (time - high) < distance
      high_max = high
      high = (high + high_min) / 2
    elsif (high + 1) * (time - high - 1) > distance
      high_min = high
      high = (high + high_max) / 2
    else
      break
    end
  end

  high - low
end

p part_one(TEST_INPUT) # should be 288
p part_one(REAL_INPUT)

p part_two(TEST_INPUT) # should be 71503
p part_two(REAL_INPUT)