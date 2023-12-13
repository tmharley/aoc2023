# frozen_string_literal: true

def import_from_file(filename)
  file = File.open(filename)
  file.read
end

TEST_INPUT = import_from_file('day13_testinput.txt')
REAL_INPUT = import_from_file('day13_input.txt')

def vertical_reflection(field, skip: nil)
  found = false
  (1...field.first.length).each do |col_num|
    next if col_num == skip

    left_check = col_num - 1
    right_check = col_num
    loop do
      wrong = false
      field.length.times do |row_num|
        if field[row_num][left_check] != field[row_num][right_check]
          wrong = true
          break
        end
      end
      break if wrong

      left_check -= 1
      right_check += 1
      if left_check.negative? || right_check >= field.first.length
        found = true
        break
      end
    end
    return col_num if found
  end
  nil
end

def horizontal_reflection(field, skip: nil)
  found = false
  field.length.times do |row_num|
    next if row_num + 1 == skip # add one because problem text uses 1-based index

    top_check = row_num
    bottom_check = row_num + 1
    loop do
      break if field[top_check] != field[bottom_check]

      top_check -= 1
      bottom_check += 1
      if top_check.negative? || bottom_check >= field.length
        found = true
        break
      end
    end
    return row_num + 1 if found # add one because problem text uses 1-based index
  end
  nil
end

def parse(input)
  input.split("\n\n")
end

def part_one(input)
  fields = parse(input)
  fields.map do |f|
    field = f.lines(chomp: true)
    vertical_reflection(field) || horizontal_reflection(field) * 100
  end.sum
end

def process(field)
  original_vert = vertical_reflection(field)
  original_horiz = original_vert ? nil : horizontal_reflection(field)
  original_value = original_vert || original_horiz * 100
  field.length.times do |i|
    field[i].length.times do |j|
      field[i][j] = (field[i][j] == '.' ? '#' : '.')
      new_value = vertical_reflection(field, skip: original_vert)
      unless new_value && new_value != original_value
        new_value = horizontal_reflection(field, skip: original_horiz)
        new_value *= 100 unless new_value.nil?
      end
      return new_value if new_value && new_value != original_value

      field[i][j] = (field[i][j] == '.' ? '#' : '.') # set back to original character
    end
  end
end

def part_two(input)
  fields = parse(input)
  fields.map do |f|
    process(f.lines(chomp: true))
  end.sum
end

p part_one(TEST_INPUT) # should be 405
p part_one(REAL_INPUT)

p part_two(TEST_INPUT) # should be 400
p part_two(REAL_INPUT)
