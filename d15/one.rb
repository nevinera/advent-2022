require "ostruct"
require "pry"
require "set"

class Point
  attr_accessor :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def distance_to(other) = (x - other.x).abs + (y - other.y).abs

  def pair = [x, y]
end

class Sensor
  attr_reader :location, :beacon, :distance

  def self.from_line(line)
    line =~ /Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/
    new(x: $1.to_i, y: $2.to_i, bx: $3.to_i, by: $4.to_i)
  end

  def initialize(x:, y:, bx:, by:)
    @location = Point.new(x, y)
    @beacon = Point.new(bx, by)
    @distance = @location.distance_to(@beacon)
  end

  def include?(p) = location.distance_to(p) <= distance

  def mapped
    result = Set.new
    (-distance .. distance).each do |dx|
      (-distance .. distance).each do |dy|
        p = Point.new(location.x + dx, location.y + dy)
        result << p.pair if include?(p)
      end
    end
    result
  end

  def entries_for(y:)
    (-distance .. distance)
      .map { |x| Point.new(x, y) }
      .select { |p| include?(p) }
  end
end

class SensorSet
  attr_reader :sensors

  def self.load(path)
    lines = File.read(path).split("\n")
    sensors = lines.map { |line| Sensor.from_line(line) }
    new(sensors)
  end

  def initialize(sensors)
    @sensors = sensors
  end

  def beacon_locations
    @_beacon_locations ||= sensors.map(&:beacon).map(&:pair).to_set
  end

  def locations
    @_locations ||= sensors.map(&:location).map(&:pair).to_set
  end

  def mapped
    @_mapped ||= sensors.map(&:mapped).reduce(&:+)
  end

  def mark(x, y)
    pair = [x, y]
    if locations.include?(pair)
      "S"
    elsif beacon_locations.include?(pair)
      "B"
    elsif mapped.include?(pair)
      "#"
    else
      "."
    end
  end

  def print(x1 = nil, x2 = nil, y1 = nil, y2 = nil)
    x1 ||= min_x
    x2 ||= max_x
    y1 ||= min_y
    y2 ||= max_y

    $stdout.print("\n   ")
    (x1..x2).each do |x|
      if x == 0
        $stdout.write("0")
      elsif x % 5 == 0
        $stdout.write("|")
      else
        $stdout.write(" ")
      end
    end

    $stdout.print("\n")
    (y1..y2).each do |y|
      $stdout.print("% 3d" % y)
      (x1..x2).each do |x|
        $stdout.print(mark(x, y))
      end
      $stdout.print("\n")
    end
    $stdout.print("\n")
  end

  def min_x = @_min_x ||= mapped.map(&:first).min
  def max_x = @_max_x ||= mapped.map(&:first).max
  def min_y = @_min_y ||= mapped.map(&:last).min
  def max_y = @_max_y ||= mapped.map(&:last).max

  def counts(&block)
    counts = {beacons: 0, sensors: 0, mapped: 0}
    mapped.each do |x, y|
      next unless block.call(x, y)
      if locations.include?([x, y])
        counts[:sensors] += 1
      elsif beacon_locations.include?([x, y])
        counts[:beacons] += 1
      elsif mapped.include?([x, y])
        counts[:mapped] += 1
      end
    end
    counts
  end
end

path = ARGV.shift
row = ARGV.shift.to_i
sensors = SensorSet.load(path)
sensors.print

puts sensors.counts { |x, y| y == row }.fetch(:mapped)
