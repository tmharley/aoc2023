def import_from_file(filename)
  file = File.open(filename)
  file.read
end

TEST_INPUT = <<~INPUT
  ...#......
  .......#..
  #.........
  ..........
  ......#...
  .#........
  .........#
  ..........
  .......#..
  #...#.....
INPUT

REAL_INPUT = import_from_file('day11_input.txt')

def expansions(universe)
  rows_to_expand = []
  cols_to_expand = (0...universe.first.length).to_a
  universe.each_with_index do |row, i|
    if row.include?('#')
      (0...row.length).each do |j|
        cols_to_expand.delete(j) if row[j] == '#'
      end
    else
      rows_to_expand << i
    end
  end
  { rows: rows_to_expand, cols: cols_to_expand }
end

def galaxies(universe)
  gals = []
  (0...universe.first.length).each do |x|
    (0...universe.length).each do |y|
      gals << [x, y] if universe[y][x] == '#'
    end
  end
  gals
end

def distance(gal1, gal2)
  (gal1[0] - gal2[0]).abs + (gal1[1] - gal2[1]).abs
end

def parse(input)
  input.lines(chomp: true)
end

def process(input, expansion_factor = 2)
  universe = parse(input)
  expansions = expansions(universe)
  galaxies = galaxies(universe)
  total = 0
  (0...galaxies.length).each do |i|
    ((i + 1)...galaxies.length).each do |j|
      total += distance(galaxies[i], galaxies[j])
      total += expansions[:cols].count do |col|
        col.between?(galaxies[i][0], galaxies[j][0]) || col.between?(galaxies[j][0], galaxies[i][0])
      end * (expansion_factor - 1)
      total += expansions[:rows].count do |col|
        col.between?(galaxies[i][1], galaxies[j][1]) || col.between?(galaxies[j][1], galaxies[i][1])
      end * (expansion_factor - 1)
    end
  end
  total
end

def part_one(input)
  process(input)
end

def part_two(input, expansion_factor)
  process(input, expansion_factor)
end

p part_one(TEST_INPUT) # should be 374
p part_one(REAL_INPUT)

p part_two(TEST_INPUT, 10) # should be 1030
p part_two(TEST_INPUT, 100) # should be 8410
p part_two(REAL_INPUT, 1_000_000)
