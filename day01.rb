def import_from_file(filename)
  file = File.open(filename)
  file.read
end

TEST_INPUT = <<~INPUT
  1abc2
  pqr3stu8vwx
  a1b2c3d4e5f
  treb7uchet
INPUT

TEST_INPUT_2 = <<~INPUT
  two1nine
  eightwothree
  abcone2threexyz
  xtwone3four
  4nineeightseven2
  zoneight234
  7pqrstsixteen
INPUT

REAL_INPUT = import_from_file('day01_input.txt')

MAP_DIGITS = { 'one' => '1',
               'two' => '2',
               'three' => '3',
               'four' => '4',
               'five' => '5',
               'six' => '6',
               'seven' => '7',
               'eight' => '8',
               'nine' => '9' }.freeze

def parse(lines)
  lines.map do |l|
    digits = []
    l.each_char { |c| digits << c.to_i if c >= '0' && c <= '9' }
    digits.first * 10 + digits.last
  end.sum
end

def part_one(input)
  lines = input.split("\n").map!(&:chomp)
  parse(lines)
end

def part_two(input)
  lines = input.split("\n").map!(&:chomp)
  lines.each do |l|
    (0...(l.length)).each do |n|
      found_front = false
      MAP_DIGITS.each do |k, v|
        if ('0'..'9').include?(l[n])
          found_front = true
          break
        end
        if l[n..].start_with?(k)
          l.sub!(k, v) # gsub! is not safe here because of strings like 'eightwo'
          found_front = true
          break
        end
      end
      break if found_front
    end
    (l.length - 1).downto(0).each do |n|
      found_back = false
      MAP_DIGITS.each do |k, v|
        if l[..n].end_with?(k)
          l.gsub!(k, v) # now we can safely gsub! because no further processing
          found_back = true
          break
        end
      end
      break if found_back
    end
  end
  parse(lines)
end

p part_one(TEST_INPUT) # should be 142
p part_one(REAL_INPUT)

p part_two(TEST_INPUT_2) # should be 281
p part_two(REAL_INPUT)