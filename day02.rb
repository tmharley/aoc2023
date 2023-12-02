# frozen_string_literal: true

def import_from_file(filename)
  file = File.open(filename)
  file.read
end

MAX = [12, 13, 14].freeze
TEST_INPUT = import_from_file('day02_testinput.txt')
REAL_INPUT = import_from_file('day02_input.txt')

def parse_input(input)
  lines = input.split("\n").map!(&:chomp)
  lines.map do |line|
    header, data = line.split(':')
    pulls = data.split(';')
    pulls.map do |pull|
      red = pull.match(/(\d+) red/)
      red = red ? red[1].to_i : 0
      green = pull.match(/(\d+) green/)
      green = green ? green[1].to_i : 0
      blue = pull.match(/(\d+) blue/)
      blue = blue ? blue[1].to_i : 0
      [red, green, blue]
    end
  end
end

def part_one(input)
  total = 0
  game_data = parse_input(input)
  (1..game_data.length).each do |i|
    valid = true
    game_data[i - 1].each do |pull|
      if pull[0] > MAX[0] || pull[1] > MAX[1] || pull[2] > MAX[2]
        valid = false
        break
      end
    end
    total += i if valid
  end
  total
end

def part_two(input)
  total = 0
  game_data = parse_input(input)
  (1..game_data.length).each do |i|
    max = [0, 0, 0]
    game_data[i - 1].each do |pull|
      (0..2).each do |j|
        max[j] = [max[j], pull[j]].max
      end
    end
    total += max.inject(&:*)
  end
  total
end

p part_one(TEST_INPUT) # should be 8
p part_one(REAL_INPUT)
p part_two(TEST_INPUT) # should be 2286
p part_two(REAL_INPUT)