# frozen_string_literal: true

def import_from_file(filename)
  file = File.open(filename)
  file.read
end

TEST_INPUT = 'rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7'

REAL_INPUT = import_from_file('day15_input.txt')

def get_hash(str)
  str.bytes.inject(0) do |total, byte|
    total += byte
    total *= 17
    total % 256
  end
end

class Lens
  attr_reader :label
  attr_accessor :focal_length

  def initialize(label, focal_length)
    @label = label
    @focal_length = focal_length
    @next_lens = nil
  end

  def next=(other_lens)
    @next_lens = other_lens
  end

  def next
    @next_lens
  end

  def remove_next
    @next_lens = @next_lens.next
  end
end

def part_one(input)
  input.split(',').map { |instruction| get_hash(instruction) }.sum
end

def part_two(input)
  boxes = Array.new(256)
  instructions = input.split(',')
  instructions.map do |inst|
    label = /\w+/.match(inst)[0]
    inst_type = /[-=]/.match(inst)[0]
    focal_length = /\d+/.match(inst)[0].to_i if inst_type == '='
    box_num = get_hash(label)
    if boxes[box_num].nil?
      next unless inst_type == '='

      boxes[box_num] = Lens.new(label, focal_length)
    else
      # iterate through the lenses in the box
      lens = boxes[box_num]
      if lens.label == label
        if inst_type == '-'
          boxes[box_num] = lens.next
        else
          lens.focal_length = focal_length
        end
      else
        until lens.next.nil?
          if lens.next.label == label
            inst_type == '-' ? lens.remove_next : lens.next.focal_length = focal_length
            break
          else
            lens = lens.next
          end
        end
        lens.next = Lens.new(label, focal_length) if inst_type == '=' && lens.next.nil?
      end
    end
  end
  total = 0
  boxes.each_with_index do |box, index|
    next if box.nil?

    box_total = 0
    i = 1
    lens = box
    loop do
      box_total += i * lens.focal_length
      lens = lens.next
      i += 1
      break if lens.nil?
    end
    total += box_total * (index + 1)
  end
  total
end

p part_one(TEST_INPUT) # should be 1320
p part_one(REAL_INPUT)

p part_two(TEST_INPUT) # should be 145
p part_two(REAL_INPUT)
