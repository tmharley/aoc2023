def import_from_file(filename)
  file = File.open(filename)
  file.read
end

TEST_INPUT = <<~INPUT.freeze
  32T3K 765
  T55J5 684
  KK677 28
  KTJJT 220
  QQQJA 483
INPUT

REAL_INPUT = import_from_file('day07_input.txt')

class Hand
  include Comparable
  attr_reader :cards, :bid

  CARD_RANKS = 'AKQJT98765432'.freeze
  CARD_RANKS_WITH_JOKER = 'AKQT98765432J'.freeze

  def initialize(cards, bid, joker: false)
    @cards = cards
    @bid = bid
    @use_joker = joker
  end

  def evaluate_hand(cards)
    sorted = cards.split('').sort.join
    case sorted
    when /#{sorted[0]}{5}/ # 5 of a kind
      7
    when /#{sorted[0]}{4}/, /#{sorted[1]}{4}/ # 4 of a kind
      6
    when /#{sorted[0]}{2}#{sorted[2]}{3}/, /#{sorted[0]}{3}#{sorted[3]}{2}/ # full house
      5
    when /#{sorted[0]}{3}/, /#{sorted[1]}{3}/, /#{sorted[2]}{3}/ # 3 of a kind
      4
    when /#{sorted[0]}{2}#{sorted[2]}{2}/, /#{sorted[0]}{2}.#{sorted[3]}{2}/, /#{sorted[1]}{2}#{sorted[3]}{2}/ # 2 pair
      3
    when /#{sorted[0]}{2}/, /#{sorted[1]}{2}/, /#{sorted[2]}{2}/, /#{sorted[3]}{2}/ # 1 pair
      2
    else
      1
    end
  end

  def score
    if @use_joker
      CARD_RANKS_WITH_JOKER[0..11].split('').map do |rank|
        evaluate_hand(cards.gsub('J', rank))
      end.max
    else
      evaluate_hand(cards)
    end
  end

  def <=>(other)
    dif = score - other.score
    return dif unless dif.zero?

    ranks_to_compare = @use_joker ? CARD_RANKS_WITH_JOKER : CARD_RANKS

    @cards.length.times do |i|
      dif = ranks_to_compare.index(other.cards[i]) - ranks_to_compare.index(@cards[i])
      return dif unless dif.zero?
    end
  end
end

def process(input, joker: false)
  hands = []
  total_score = 0
  input.lines(chomp: true).each do |line|
    cards, bid = line.split(' ')
    hands << Hand.new(cards, bid.to_i, joker: joker)
  end
  hands.sort!
  hands.length.times do |i|
    total_score += hands[i].bid * (i + 1)
  end
  total_score
end

def part_one(input)
  process(input)
end

def part_two(input)
  process(input, joker: true)
end

p part_one(TEST_INPUT) # should be 6440
p part_one(REAL_INPUT)

p part_two(TEST_INPUT) # should be 5905
p part_two(REAL_INPUT)