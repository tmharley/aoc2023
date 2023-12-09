# frozen_string_literal: true

def import_from_file(filename)
  file = File.open(filename)
  file.read
end

TEST_INPUT = <<~INPUT.freeze
  0 3 6 9 12 15
  1 3 6 10 15 21
  10 13 16 21 30 45
INPUT

REAL_INPUT = import_from_file('day09_input.txt')

def evaluate_line(values)
  diffs = (1...values.length).map { |i| values[i] - values[i - 1] }
  return values.last if diffs.all?(&:zero?)

  values.last + evaluate_line(diffs)
end

def part_one(input)
  input.lines.map do |line|
    evaluate_line(line.split(' ').map(&:to_i))
  end.sum
end

def part_two(input)
  input.lines.map do |line|
    evaluate_line(line.split(' ').map(&:to_i).reverse)
  end.sum
end

p part_one(TEST_INPUT) # should be 114
p part_one(REAL_INPUT)

p part_two(TEST_INPUT) # should be 2
p part_two(REAL_INPUT)