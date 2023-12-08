def import_from_file(filename)
  file = File.open(filename)
  file.read
end

TEST_INPUT_1 = <<~INPUT.freeze
  RL
  
  AAA = (BBB, CCC)
  BBB = (DDD, EEE)
  CCC = (ZZZ, GGG)
  DDD = (DDD, DDD)
  EEE = (EEE, EEE)
  GGG = (GGG, GGG)
  ZZZ = (ZZZ, ZZZ)
INPUT

TEST_INPUT_2 = <<~INPUT.freeze
  LLR
  
  AAA = (BBB, BBB)
  BBB = (AAA, ZZZ)
  ZZZ = (ZZZ, ZZZ)
INPUT

TEST_INPUT_3 = <<~INPUT.freeze
  LR
  
  11A = (11B, XXX)
  11B = (XXX, 11Z)
  11Z = (11B, XXX)
  22A = (22B, XXX)
  22B = (22C, 22C)
  22C = (22Z, 22Z)
  22Z = (22B, 22B)
  XXX = (XXX, XXX)
INPUT

REAL_INPUT = import_from_file('day08_input.txt')

def parse(input)
  directions, node_list = input.split("\n\n")
  nodes = {}
  node_list.lines.each do |line|
    md = line.match(/(\w+) = \((\w+), (\w+)\)/)
    nodes[md[1]] = [md[2], md[3]]
  end
  [directions, nodes]
end

def lcm(num_list)
  prime_factor_lists = num_list.map do |num|
    factors = []
    rem = num
    i = 2
    while i < Math.sqrt(rem)
      if (rem % i).zero?
        factors << i
        rem /= i
      else
        i += 1
      end
    end
    factors << rem
    factors
  end
  removed_factors = []
  prime_factor_lists.first.each do |factor|
    if prime_factor_lists.all? { |list| list.include?(factor) }
      prime_factor_lists.each { |list| list.delete(factor) }
      removed_factors << factor
    end
  end
  prime_factor_lists.flatten.inject(&:*) * removed_factors.inject(1, &:*)
end

def part_one(input)
  directions, nodes = parse(input)
  steps = 0
  loc = 'AAA'
  until loc == 'ZZZ'
    dir = directions[steps % directions.length]
    case dir
    when 'L'
      loc = nodes[loc][0]
    when 'R'
      loc = nodes[loc][1]
    else
      raise 'Invalid direction'
    end
    steps += 1
  end
  steps
end

def part_two(input)
  directions, nodes = parse(input)
  locs = nodes.keys.select { |k| k.end_with?('A') }
  steps = Array.new(locs.length) { 0 }
  locs.each_with_index do |l, i|
    loc_steps = 0
    until l.end_with?('Z')
      dir = directions[loc_steps % directions.length]
      case dir
      when 'L'
        l = nodes[l][0]
      when 'R'
        l = nodes[l][1]
      else
        raise 'Invalid direction'
      end
      loc_steps += 1
    end
    steps[i] = loc_steps
  end
  lcm(steps)
end

p part_one(TEST_INPUT_1) # should be 2
p part_one(TEST_INPUT_2) # should be 6
p part_one(REAL_INPUT)

p part_two(TEST_INPUT_3) # should be 6
p part_two(REAL_INPUT)