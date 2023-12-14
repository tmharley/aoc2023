def import_from_file(filename)
  file = File.open(filename)
  file.read
end

ITERATIONS = 1_000_000_000

TEST_INPUT = <<~INPUT
  O....#....
  O.OO#....#
  .....##...
  OO.#O....O
  .O.....O#.
  O.#..O.#.#
  ..O..#O..O
  .......O..
  #....###..
  #OO..#....
INPUT

REAL_INPUT = import_from_file('day14_input.txt')

def shift_north(field)
  field.each_with_index do |row, y|
    (0...row.length).each do |x|
      if row[x] == '.'
        ((y + 1)...field.length).each do |yy|
          break if field[yy][x] == '#' # found a cube, nothing moves past it

          if field[yy][x] == 'O' # move it north
            field[y][x] = 'O'
            field[yy][x] = '.'
            break
          end
        end
      end
    end
  end
  field
end

def shift_south(field)
  shift_north(field.reverse).reverse
end

def shift_west(field)
  field.each_with_index do |row, y|
    (0...row.length).each do |x|
      if row[x] == '.'
        ((x + 1)...row.length).each do |xx|
          break if field[y][xx] == '#' # found a cube, nothing moves past it

          if field[y][xx] == 'O' # move it west
            field[y][x] = 'O'
            field[y][xx] = '.'
            break
          end
        end
      end
    end
  end
  field
end

def shift_east(field)
  field.each(&:reverse!)
  shift_west(field).each(&:reverse!)
end

def load(field)
  total = 0
  field.each_with_index do |row, index|
    total += row.count('O') * (field.length - index)
  end
  total
end

def parse_input(input)
  input.lines(chomp: true)
end

def part_one(input)
  shifted = shift_north(parse_input(input))
  load(shifted)
end

def part_two(input)
  field = parse_input(input)
  loads = []
  ITERATIONS.times do |i|
    field = shift_north(field)
    field = shift_west(field)
    field = shift_south(field)
    field = shift_east(field)
    loads << load(field)

    # loop detection
    (2..(loads.length / 2)).each do |j|
      if (the_loop = loads[-j...]) == loads[(-2*j)...-j]
        return the_loop[(ITERATIONS - i - 2) % j]
      end
    end
  end
end

pp part_one(TEST_INPUT) # should be 136
pp part_one(REAL_INPUT)

p part_two(TEST_INPUT) # should be 64
p part_two(REAL_INPUT)