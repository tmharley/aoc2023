def import_from_file(filename)
  file = File.open(filename)
  file.read
end

TEST_INPUT = <<~INPUT.freeze
  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...$.*....
  .664.598..
INPUT

REAL_INPUT = import_from_file('day03_input.txt')

class PartNumber
  attr_reader :number, :gear

  def initialize(number, location)
    @number = number
    @length = number.to_s.length
    @location = location
  end

  def bounding_box
    {
      x_min: [@location[0] - 1, 0].max,
      x_max: @location[0] + 1,
      y_min: [@location[1] - 1, 0].max,
      y_max: @location[1] + @length + 1
    }
  end

  def set_gear(x, y)
    @gear = [x, y]
  end
end

def symbol?(char)
  char != '.' && !('0'..'9').include?(char)
end

def gear?(char)
  char == '*'
end

def digit?(char)
  ('0'..'9').include?(char)
end

def part_one(input)
  part_numbers = []
  lines = input.lines(chomp: true)
  lines.each_with_index do |line, i|
    num_start = nil
    num = 0
    (0...line.length).each do |j|
      if digit?(line[j])
        if num_start
          num = num * 10 + line[j].to_i
        else
          num_start = j
          num = line[j].to_i
        end
      elsif num_start
        part_numbers << PartNumber.new(num, [i, num_start])
        num_start = nil
        num = 0
      end
    end
    part_numbers << PartNumber.new(num, [i, num_start]) if num_start # number at end of line
  end
  part_numbers.select! do |part_num|
    valid = false
    bb = part_num.bounding_box
    (bb[:x_min]..bb[:x_max]).each do |x|
      next if x >= lines.length
      test_range = lines[x][bb[:y_min]...bb[:y_max]]
      test_range.split('').each_with_index do |char, y|
        part_num.set_gear(x, y + bb[:y_min]) if gear?(char)
        valid = symbol?(char)
        break if valid
      end
      break if valid
    end
    valid
  end
  part_numbers
end

def part_two(input)
  part_numbers = part_one(input)
  gears = {}
  part_numbers.each do |pn|
    if pn.gear
      if gears.key?(pn.gear)
        gears[pn.gear] << pn.number
      else
        gears[pn.gear] = Array(pn.number)
      end
    end
  end
  gears.map do |gear, part_nums|
    part_nums.length == 2 ? part_nums.inject(&:*) : 0
  end.sum
end

p part_one(TEST_INPUT).map(&:number).sum # should be 4361
p part_one(REAL_INPUT).map(&:number).sum

p part_two(TEST_INPUT) # should be 467835
p part_two(REAL_INPUT)