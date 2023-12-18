# frozen_string_literal: true

def import_from_file(filename)
  file = File.open(filename)
  file.read
end

TEST_INPUT = <<~INPUT
  2413432311323
  3215453535623
  3255245654254
  3446585845452
  4546657867536
  1438598798454
  4457876987766
  3637877979653
  4654967986887
  4564679986453
  1224686865563
  2546548887735
  4322674655533
INPUT

NORTH = 0
EAST = 90
SOUTH = 180
WEST = 270

REAL_INPUT = import_from_file('day17_input.txt')

def position_invalid?(y, x, grid_size)
  y.negative? || x.negative? || y >= grid_size || x >= grid_size
end

def move(position, direction, grid_size)
  # p "Moving from position #{position} in direction #{direction}"
  new_position = case direction
                 when NORTH
                   [position[0] - 1, position[1]]
                 when EAST
                   [position[0], position[1] + 1]
                 when SOUTH
                   [position[0] + 1, position[1]]
                 when WEST
                   [position[0], position[1] - 1]
                 else
                   raise 'invalid direction'
                 end
  if position_invalid?(new_position[0], new_position[1], grid_size)
    # p "Moving to invalid position"
    nil
  else
    # p "Moving to position #{new_position}"
    new_position
  end
end

def to_key(last_three_moves)
  case last_three_moves.last
  when NORTH
    if last_three_moves[-2] == NORTH
      last_three_moves.first == NORTH ? :n3 : :n2
    else
      :n1
    end
  when EAST
    if last_three_moves[-2] == EAST
      last_three_moves.first == EAST ? :e3 : :e2
    else
      :e1
    end
  when SOUTH
    if last_three_moves[-2] == SOUTH
      last_three_moves.first == SOUTH ? :s3 : :s2
    else
      :s1
    end
  when WEST
    if last_three_moves[-2] == WEST
      last_three_moves.first == WEST ? :w3 : :w2
    else
      :w1
    end
  end
end

def part_one(input)
  grid = input.lines(chomp: true).map { |line| line.split('').map(&:to_i) }
  min_heat_loss = Array.new(grid.length) { Array.new(grid.first.length) { 1_000_000 } }
  min_heat_loss = Array.new(grid.length) do
    Array.new(grid.first.length) do
      {
        n1: 1_000_000, n2: 1_000_000, n3: 1_000_000,
        e1: 1_000_000, e2: 1_000_000, e3: 1_000_000,
        s1: 1_000_000, s2: 1_000_000, s3: 1_000_000,
        w1: 1_000_000, w2: 1_000_000, w3: 1_000_000
      }
    end
  end
  start_point = min_heat_loss[0][0]
  start_point.each_key { |key| start_point[key] = 0 } # no need to move to get here
  paths = [{ position: [0, 0], last_three_moves: [nil, nil, nil], heat_lost: 0 }]
  until paths.empty?
    path = paths.first
    # p "Paths: #{paths.length}"
    last_move = path[:last_three_moves].last
    allowable_moves = case last_move
                      when NORTH
                        [WEST, NORTH, EAST]
                      when EAST
                        [NORTH, EAST, SOUTH]
                      when SOUTH
                        [EAST, SOUTH, WEST]
                      when WEST
                        [SOUTH, WEST, NORTH]
                      else
                        [NORTH, EAST, SOUTH, WEST]
                      end
    if path[:last_three_moves].all? { |m| m == last_move }
      # p "#{path} moved 3 times in same direction"
      allowable_moves.delete(last_move)
    end
    # allowable_moves.delete(last_move) if path[:last_three_moves].all? { |m| m == last_move }
    paths.delete(path)
    allowable_moves.each do |dir|
      new_position = move(path[:position], dir, grid.length)
      next if new_position.nil?

      last_three_moves = path[:last_three_moves].dup
      last_three_moves.shift
      last_three_moves << dir
      key = to_key(last_three_moves)
      heat_lost = path[:heat_lost] + grid[new_position[0]][new_position[1]]
      next if heat_lost >= min_heat_loss[new_position[0]][new_position[1]][key]

      new_path = { position: new_position, last_three_moves: last_three_moves, heat_lost: heat_lost }
      paths << new_path
      min_heat_loss[new_position[0]][new_position[1]][key] = heat_lost
    end
  end
  min_heat_loss[grid.length - 1][grid.first.length - 1].values.min
end

p part_one(TEST_INPUT) # should be 102
p part_one(REAL_INPUT)