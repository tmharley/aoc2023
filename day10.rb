# frozen_string_literal: true

def import_from_file(filename)
  file = File.open(filename)
  file.read
end

TEST_INPUT = <<~INPUT
  7-F7-
  .FJ|7
  SJLL7
  |F--J
  LJ.LJ
INPUT

TEST_INPUT_2 = <<~INPUT
  ..........
  .S------7.
  .|F----7|.
  .||....||.
  .||....||.
  .|L-7F-J|.
  .|..||..|.
  .L--JL--J.
  ..........
INPUT

TEST_INPUT_3 = <<~INPUT
  .F----7F7F7F7F-7....
  .|F--7||||||||FJ....
  .||.FJ||||||||L7....
  FJL7L7LJLJ||LJ.L-7..
  L--J.L7...LJS7F-7L7.
  ....F-J..F7FJ|L7L7L7
  ....L7.F7||L7|.L7L7|
  .....|FJLJ|FJ|F7|.LJ
  ....FJL-7.||.||||...
  ....L---J.LJ.LJLJ...
INPUT

TEST_INPUT_4 = <<~INPUT
  FF7FSF7F7F7F7F7F---7
  L|LJ||||||||||||F--J
  FL-7LJLJ||||||LJL-77
  F--JF--7||LJLJ7F7FJ-
  L---JF-JLJ.||-FJLJJ7
  |F|F-JF---7F7-L7L|7|
  |FFJF7L7F-JF7|JL---7
  7-L-JL7||F7|L7F-7F7|
  L.L7LFJ|||||FJL7||LJ
  L7JLJL-JLJLJL--JLJ.L
INPUT

REAL_INPUT = import_from_file('day10_input.txt')

def parse(input)
  tiles = {}
  pipes = {}
  start_point = nil
  rows = input.lines(chomp: true)
  rows.each_with_index do |row, y|
    (0...row.length).each do |x|
      pipes[[x, y]] = row[x]
      tiles[[x, y]] = case row[x]
                      when '|'
                        [[x, y - 1], [x, y + 1]]
                      when '-'
                        [[x + 1, y], [x - 1, y]]
                      when 'L'
                        [[x, y - 1], [x + 1, y]]
                      when 'J'
                        [[x, y - 1], [x - 1, y]]
                      when '7'
                        [[x, y + 1], [x - 1, y]]
                      when 'F'
                        [[x + 1, y], [x, y + 1]]
                      when 'S'
                        start_point = [x, y]
                        nil # we'll fill this one out when we're done
                      end
    end
  end
  tiles[start_point] = tiles.select { |k, v| v&.include?(start_point) }.keys
  [tiles, pipes, start_point]
end

def pipe?(symbol)
  symbol != '.'
end

def part_one(input)
  tiles, pipes, start_point = parse(input)
  loc = start_point
  prev_loc = nil
  steps = 0
  loop do
    if tiles[loc][0] == prev_loc
      prev_loc = loc
      loc = tiles[loc][1]
    else
      prev_loc = loc
      loc = tiles[loc][0]
    end
    steps += 1
    break if loc == start_point
  end
  (steps + 1) / 2
end

def part_two(input)
  # let's just assume we're traveling counterclockwise and hope for the best
  tiles, pipes, start_point = parse(input)
  loc = start_point
  prev_loc = nil
  inside_locations = []
  main_loop = []
  loop do
    if tiles[loc][1] == prev_loc
      prev_loc = loc
      loc = tiles[loc][0]
    else
      prev_loc = loc
      loc = tiles[loc][1]
    end
    main_loop << loc
    break if loc == start_point
  end
  loop do
    if tiles[loc][1] == prev_loc
      prev_loc = loc
      loc = tiles[loc][0]
    else
      prev_loc = loc
      loc = tiles[loc][1]
    end
    # which direction did we just move?
    if loc[0] == prev_loc[0] # either north or south
      if loc[1] == prev_loc[1] + 1 # moved south, so came from north
        case pipes[loc]
        when '|'
          # inside is to the west
          loc_to_check = [loc[0] - 1, loc[1]]
          unless main_loop.include?(loc_to_check) || inside_locations.include?(loc_to_check)
            inside_locations << loc_to_check
          end
        when 'L'
          # inside is to the west/south
          locs_to_check = [
            [loc[0] - 1, loc[1]], # west
            [loc[0], loc[1] + 1], # south
            [loc[0] - 1, loc[1] + 1] # southwest
          ]
          locs_to_check.each do |ltc|
            inside_locations << ltc unless main_loop.include?(ltc) || inside_locations.include?(ltc)
          end
        when 'J'
          # inside is northwest, already covered
        end
      else
        # moved north, so came from south
        case pipes[loc]
        when '|' # inside is to the east
          loc_to_check = [loc[0] + 1, loc[1]]
          unless main_loop.include?(loc_to_check) || inside_locations.include?(loc_to_check)
            inside_locations << loc_to_check
          end
        when '7' # inside is to the east/north
          locs_to_check = [
            [loc[0] + 1, loc[1]], # east
            [loc[0], loc[1] - 1], # north
            [loc[0] + 1, loc[1] - 1] # northeast
          ]
          locs_to_check.each do |ltc|
            inside_locations << ltc unless main_loop.include?(ltc) || inside_locations.include?(ltc)
          end
        when 'F' # inside is southeast, already covered
        end
      end
    else
      # either east or west
      if loc[0] == prev_loc[0] + 1 # moved east, so came from west
        case pipes[loc]
        when '-' # inside is to the south
          loc_to_check = [loc[0], loc[1] + 1]
          unless main_loop.include?(loc_to_check) || inside_locations.include?(loc_to_check)
            inside_locations << loc_to_check
          end
        when 'J' # inside is to the south/east
          locs_to_check = [
            [loc[0] + 1, loc[1]], # east
            [loc[0], loc[1] + 1], # south
            [loc[0] + 1, loc[1] + 1] # southeast
          ]
          locs_to_check.each do |ltc|
            inside_locations << ltc unless main_loop.include?(ltc) || inside_locations.include?(ltc)
          end
        when '7' # inside is southwest, already covered
        end
      else
        # moved west, so came from east
        case pipes[loc]
        when '-' # inside is to the north
          loc_to_check = [loc[0], loc[1] - 1]
          unless main_loop.include?(loc_to_check) || inside_locations.include?(loc_to_check)
            inside_locations << loc_to_check
          end
        when 'F' # inside is to the north/west
          locs_to_check = [
            [loc[0] - 1, loc[1]], # west
            [loc[0], loc[1] - 1], # north
            [loc[0] - 1, loc[1] - 1] # northwest
          ]
          locs_to_check.each do |ltc|
            inside_locations << ltc unless main_loop.include?(ltc) || inside_locations.include?(ltc)
          end
        when 'L' # inside is northeast, already covered
        end
      end
    end
    break if loc == start_point
  end
  main_loop.each do |ml|
    pipes[ml] = 'X'
  end
  inside_locations.each do |il|
    pipes[il] = 'I'
  end
  # look for stuff embedded multiple levels in
  pipes.each do |k, v|
    next if %w[X I].include?(v)

    check = [pipes[[k[0] - 1, k[1]]], pipes[[k[0] + 1, k[1]]], pipes[[k[0], k[1] - 1]], pipes[[k[0], k[1] + 1]]]
    pipes[k] = 'I' if check.any? { |p| p == 'I' } && check.none? { |p| p == 'X' }
  end
  pipes.keys.map(&:last).max.times do |i|
    p pipes.select { |k, v| k.last == i }.values.join('')
  end
  pipes.values.select { |p| p == 'I' }.length
end

p part_one(TEST_INPUT) # should be 8
p part_one(REAL_INPUT)

# p part_two(TEST_INPUT_2) # should be 4 - requires reversing cw/ccw
p part_two(TEST_INPUT_3) # should be 8
p part_two(TEST_INPUT_4) # should be 10
p part_two(REAL_INPUT)