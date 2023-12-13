def import_from_file(filename)
  file = File.open(filename)
  file.read
end

TEST_INPUT = <<~INPUT
  ???.### 1,1,3
  .??..??...?##. 1,1,3
  ?#?#?#?#?#?#?#? 1,3,1,6
  ????.#...#... 4,1,1
  ????.######..#####. 1,6,5
  ?###???????? 3,2,1
INPUT

REAL_INPUT = import_from_file('day12_input.txt')

def invalid?(springs, groups)
  # p "Checking validity of #{springs} against #{groups}"
  # return false if groups.empty?
  first_unknown = springs.index('?')
  first_broken = springs.index('#')
  return first_broken if groups.empty?
  return false if first_unknown && first_unknown < (first_broken || springs.length)
  return true if springs.length < groups.sum + groups.length - 1

  num_broken = 1
  if first_broken
    ((first_broken + 1)...springs.length).each do |i|
      return true if num_broken > groups.first
      return false if springs[i] == '?' # we can't say for sure it's invalid yet
      break unless springs[i] == '#'

      num_broken += 1
    end
    return true unless num_broken == groups.first
  end
  invalid?(springs[((first_broken || 0) + num_broken)...], groups[(first_broken ? 1 : 0)...])
end

def parse(input, repeat_times: 1)
  springs = []
  groups = []
  input.lines.map do |line|
    spr, group_list = line.split(' ')
    spr_orig = spr.dup
    (repeat_times - 1).times do |i|
      spr << '?'
      spr << spr_orig
    end
    springs << spr
    groups << group_list.split(',').map(&:to_i) * repeat_times
  end
  [springs, groups]
end

def with_broken_spring(springs)
  springs.sub('?', '#')
end

def with_unbroken_spring(springs)
  springs.sub('?', '.')
end

def resolved?(springs)
  springs.index('?').nil?
end

def evaluate(springs, groups)
  # p "Evaluating #{springs}"
  if invalid?(springs, groups)
    # p "#{springs} is invalid"
    return 0
  end
  if resolved?(springs)
    # p "#{springs} is resolved"
    return 1
  end
  # return 1 if resolved?(springs)
  evaluate(with_broken_spring(springs), groups) + evaluate(with_unbroken_spring(springs), groups)
end

def part_one(input)
  springs_list, groups_list = parse(input)
  total = 0
  springs_list.length.times do |i|
    total += evaluate(springs_list[i], groups_list[i])
  end
  total
end

def part_two(input)
  springs_list, groups_list = parse(input, repeat_times: 5)
  total = 0
  springs_list.length.times do |i|
    p "#{i}: #{springs_list[i]} #{groups_list[i]}"
    total += evaluate(springs_list[i], groups_list[i])
  end
  total
end

p part_one(TEST_INPUT) # should be 21
p part_one(REAL_INPUT)

p part_two(TEST_INPUT) # should be 525152