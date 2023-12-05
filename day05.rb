require 'set'

MAP_TYPES = %w[
seed-to-soil
soil-to-fertilizer
fertilizer-to-water
water-to-light
light-to-temperature
temperature-to-humidity
humidity-to-location
]

def import_from_file(filename)
  file = File.open(filename)
  file.read
end

TEST_INPUT = import_from_file('day05_testinput.txt')
REAL_INPUT = import_from_file('day05_input.txt')

def parse(input)
  maps = {}
  sections = input.split("\n\n")
  sections[1..].each do |section|
    map_type = section.lines.first.match(/([\w-]+) map/)[1]
    maps[map_type] = []
    section.lines[1..].each do |line|
      dest, source, length = line.split(' ').map(&:to_i)
      dest_range = (dest...(dest + length))
      source_range = (source...(source + length))
      maps[map_type] << { dest_range: dest_range, source_range: source_range }
    end
  end
  maps
end

def process(seeds, maps)
  (0...seeds.length).each do |index|
    MAP_TYPES.each do |type|
      maps[type].each do |map|
        if map[:source_range].include?(seeds[index])
          seeds[index] = seeds[index] - map[:source_range].min + map[:dest_range].min
          break
        end
      end
    end
  end
  seeds
end

def process_map(source_ranges, map_list)
  dest_ranges = Set.new
  ranges_to_check = Set.new
  begin
    source_ranges.merge(ranges_to_check)
    ranges_to_check.clear
    source_ranges.each do |range|
      map_list.each do |map|
        if map[:source_range].cover?(range)
          # this set is fully included in a source range
          new_min = range.min - map[:source_range].min + map[:dest_range].min
          new_max = range.max - map[:source_range].min + map[:dest_range].min + 1
          new_range = new_min...new_max
          dest_ranges << new_range unless dest_ranges.any? {|dr| dr.cover?(new_range)}
          source_ranges.delete(range)
        elsif map[:source_range].cover?(range.min)
          # process included subrange
          new_min = range.min - map[:source_range].min + map[:dest_range].min
          new_max = map[:source_range].max - map[:source_range].min + map[:dest_range].min + 1
          new_range = new_min...new_max
          dest_ranges << new_range unless dest_ranges.any? {|dr| dr.cover?(new_range)}
          # keep excluded subrange
          range2 = ((map[:source_range].max + 1)...(range.max + 1))
          ranges_to_check << range2 unless range2.min == range2.max
          source_ranges.delete(range)
          break
        elsif map[:source_range].cover?(range.max)
          # process included subrange
          new_min = map[:dest_range].min
          new_max = range.max - map[:source_range].min + map[:dest_range].min + 1
          new_range = new_min...new_max
          dest_ranges << new_range unless dest_ranges.any? {|dr| dr.cover?(new_range)}
          # keep excluded subrange
          range1 = (range.min...map[:source_range].min)
          ranges_to_check << range1 unless range1.min == range1.max
          source_ranges.delete(range)
          break
        end
      end
    end
  end until ranges_to_check.empty?
  dest_ranges.merge(source_ranges)
end

def process2(seeds, maps)
  MAP_TYPES.each do |type|
    seeds = seeds.to_a
    (0...seeds.length).each do |i|
      range = seeds[i]
      ((i+1)...seeds.length).each do |j|
        seeds[i] = nil if seeds[j].cover?(range)
      end
    end
    seeds.compact!
    (seeds.length - 1).downto(0).each do |i|
      range = seeds[i]
      (i-1).downto(0).each do |j|
        seeds[i] = nil if seeds[j].cover?(range)
      end
    end
    seeds = seeds.to_set
    seeds = process_map(seeds, maps[type])
  end
  seeds
end

def part_one(input)
  seeds = input.split("\n\n").first.split(': ')[1].split(' ').map(&:to_i)
  maps = parse(input)
  process(seeds, maps).min
end

def part_two(input)
  seed_params = input.split("\n\n").first.split(': ')[1].split(' ').map(&:to_i)
  seeds = Set.new
  (0...(seed_params.length / 2)).each do |i|
    seeds << (seed_params[i * 2]...(seed_params[i * 2] + seed_params[i * 2 + 1]))
  end
  maps = parse(input)
  process2(seeds, maps).map(&:min).min
end

p part_one(TEST_INPUT) # should be 35
p part_one(REAL_INPUT)

p part_two(TEST_INPUT) # should be 46
p part_two(REAL_INPUT)