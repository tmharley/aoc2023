# frozen_string_literal: true

def import_from_file(filename)
  file = File.open(filename)
  file.read
end

TEST_INPUT = <<~INPUT
  Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
  Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
  Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
  Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
  Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
  Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
INPUT

REAL_INPUT = import_from_file('day04_input.txt')

def parse(input)
  input.lines(chomp: true).map do |card|
    header, nums = card.split(':')
    wn, nyh = nums.split(' | ')
    { winning_numbers: wn.split(' ').reject(&:empty?).map!(&:to_i),
      numbers_you_have: nyh.split(' ').reject(&:empty?).map!(&:to_i) }
  end
end

def part_one(input)
  cards = parse(input)
  cards.map do |c|
    count = (c[:winning_numbers] & c[:numbers_you_have]).length
    count.zero? ? 0 : 2**(count - 1)
  end.sum
end

def part_two(input)
  cards = parse(input)
  card_counts = Array.new(cards.length) { 1 }
  cards.each_with_index do |card, i|
    matches = (card[:winning_numbers] & card[:numbers_you_have]).length
    ((i + 1)...(i + 1 + matches)).each do |ii|
      card_counts[ii] += card_counts[i]
    end
  end
  card_counts.sum
end

p part_one(TEST_INPUT) # should be 13
p part_one(REAL_INPUT)

p part_two(TEST_INPUT) # should be 30
p part_two(REAL_INPUT)