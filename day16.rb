# frozen_string_literal: true

def import_from_file(filename)
  file = File.open(filename)
  file.read
end

NORTH = 0
EAST = 90
SOUTH = 180
WEST = 270

TEST_INPUT = <<~INPUT
  .|...\\....
  |.-.\\.....
  .....|-...
  ........|.
  ..........
  .........\\
  ..../.\\\\..
  .-.-/..|..
  .|....-|.\\
  ..//.|....
INPUT

REAL_INPUT = import_from_file('day16_input.txt')

def process_tile(beam_direction, tile_contents)
  case tile_contents
  when '/'
    return NORTH if beam_direction == EAST
    return WEST if beam_direction == SOUTH
    return SOUTH if beam_direction == WEST
    return EAST if beam_direction == NORTH
  when '\\'
    return SOUTH if beam_direction == EAST
    return EAST if beam_direction == SOUTH
    return NORTH if beam_direction == WEST
    return WEST if beam_direction == NORTH
  when '-'
    [EAST, WEST].include?(beam_direction) ? beam_direction : [WEST, EAST]
  when '|'
    [NORTH, SOUTH].include?(beam_direction) ? beam_direction : [NORTH, SOUTH]
  else
    beam_direction
  end
end

def move(old_position, direction)
  case direction
  when EAST
    [old_position[0], old_position[1] + 1]
  when WEST
    [old_position[0], old_position[1] - 1]
  when SOUTH
    [old_position[0] + 1, old_position[1]]
  when NORTH
    [old_position[0] - 1, old_position[1]]
  else
    raise 'bad direction'
  end
end

def process_grid(grid, starting_beam)
  beams = [starting_beam]
  moved_through = Array.new(grid.length) { Array.new(grid.first.length) { [] } }
  moved_through[starting_beam[:position][0]][starting_beam[:position][1]] << starting_beam[:direction]
  until beams.empty?
    beam = beams.first
    new_directions = Array(process_tile(beam[:direction], grid[beam[:position][0]][beam[:position][1]]))
    beams.delete(beam)
    new_directions.each_with_index do |nd, j|
      new_position = move(beam[:position], nd)
      unless new_position[0].negative? || new_position[0] >= grid.length || new_position[1].negative? || new_position[1] >= grid.first.length
        unless moved_through[new_position[0]][new_position[1]].include?(nd)
          beams << { position: move(beam[:position], nd), direction: nd }
          moved_through[new_position[0]][new_position[1]] << nd
        end
      end
    end
  end
  moved_through.map do |row|
    row.count(&:any?)
  end.sum
end

def part_one(input)
  grid = input.lines(chomp: true)
  starting_beam = { position: [0, 0], direction: EAST }
  process_grid(grid, starting_beam)
end

def part_two(input)
  grid = input.lines(chomp: true)
  tiles_energized = []
  grid.length.times do |i|
    starting_beam = { position: [i, 0], direction: EAST }
    tiles_energized << process_grid(grid, starting_beam)
    starting_beam = { position: [i, grid.first.length - 1], direction: WEST }
    tiles_energized << process_grid(grid, starting_beam)
  end
  grid.first.length.times do |i|
    starting_beam = { position: [0, i], direction: SOUTH }
    tiles_energized << process_grid(grid, starting_beam)
    starting_beam = { position: [grid.length - 1, i], direction: NORTH }
    tiles_energized << process_grid(grid, starting_beam)
  end
  tiles_energized.max
end

p part_one(TEST_INPUT) # should be 46
p part_one(REAL_INPUT)

p part_two(TEST_INPUT) # should be 51
p part_two(REAL_INPUT)
