require "pry"
require "set"
require "memery"
require "json"

def distance(p1, p2) = (p1.first - p2.first).abs + (p1.last - p2.last).abs

class Sensor
  include Memery
  attr_reader :location, :beacon, :range, :boundary

  def self.from_line(line, boundary)
    line =~ /Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/
    new(x: $1.to_i, y: $2.to_i, bx: $3.to_i, by: $4.to_i, boundary: boundary)
  end

  def initialize(x:, y:, bx:, by:, boundary:)
    @location = [x, y]
    @beacon = [bx, by]
    @range = distance(@location, @beacon)
    @boundary = boundary
  end

  memoize def x = location.first
  memoize def y = location.last

  def mapped?(other) = distance(location, other) <= range

  memoize def bounding_range = (0..boundary)
  def in_bounds?(p) = bounding_range.include?(p.first) && bounding_range.include?(p.last)

  memoize def adjacencies
    warn "calculating adjacencies..."
    s = Set.new
    each_adjacency { |p| s << p if in_bounds?(p) }
    s
  end

  def each_adjacency(&block)
    (0..range).each do |d|
      yield [x + d, y + range - d + 1] # up one from the edge (upper right side)
      yield [x + d + 1, y - range + d] # right one from the edge (lower right side)
      yield [x - d, y + range - d - 1] # down one from the edge (lower left side)
      yield [x - d - 1, y - range + d] # left one from the edge (upper left side)
    end
  end
end

class SensorSet
  include Memery
  attr_reader :sensors, :boundary

  def self.load(path, boundary)
    lines = File.read(path).split("\n")
    sensors = lines.map { |line| Sensor.from_line(line, boundary) }
    new(sensors, boundary)
  end

  def initialize(sensors, boundary)
    @sensors, @boundary = sensors, boundary
  end

  def mapped?(p) = sensors.any? { |s| s.mapped?(p) }

  memoize def bounding_range = (0..boundary)
  def in_bounds?(p) = bounding_range.include?(p.first) && bounding_range.include?(p.last)

  def tuning_frequency(p) = p.first * 4_000_000 + p.last

  # we _know_ there's only one such point, which means it must be adjacent to at least
  # one of the boundaries (or the adjacent point(s) would also quality)
  memoize def potentials = sensors.map(&:adjacencies).reduce(&:+)
  memoize def in_bounds_potentials = potentials.select { |p| in_bounds?(p) }.to_set
  memoize def unmapped = in_bounds_potentials.detect { |p| !mapped?(p) }

  memoize def first_unmapped
    sensors.each do |s|
      s.each_adjacency do |p|
        next unless in_bounds?(p)
        next if mapped?(p)
        return p
      end
    end
  end
end

path = ARGV.shift
boundary = ARGV.shift.to_i
sensors = SensorSet.load(path, boundary)
puts "first unmapped: #{sensors.first_unmapped.to_json}"
puts "tuning frequency: #{sensors.tuning_frequency(sensors.first_unmapped)}"


# old solution - collect em, process em, search
# puts "potentials: #{sensors.potentials.count}"
# puts "in_bounds_potentials: #{sensors.in_bounds_potentials.count}"
# puts "unmapped: #{sensors.unmapped.to_json}"
# puts "tuning frequency: #{sensors.tuning_frequency}"
