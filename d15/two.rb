require "ostruct"
require "pry"
require "set"

def distance(p1, p2) = (p1.first - p2.first).abs + (p1.last - p2.last).abs

class Sensor
  attr_reader :location, :beacon, :range

  def self.from_line(line)
    line =~ /Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/
    new(x: $1.to_i, y: $2.to_i, bx: $3.to_i, by: $4.to_i)
  end

  def initialize(x:, y:, bx:, by:)
    @location = [x, y]
    @beacon = [bx, by]
    @range = distance(@location, @beacon)
  end

  def mapped?(other) = distance(location, other) <= range

  def mapped_positions(y:)
    (-range .. range)
      .map { |dx| [location.first + dx, y] }
      .select { |p| mapped?(p) }
      .map(&:first)
      .to_set
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

  def mapped_positions(y:) = sensors.map { |s| s.mapped_positions(y: y) }.reduce(&:+)
  def beacon_positions(y:) = sensors.map(&:beacon).select { |bx, by| y == by }.map(&:first).to_set
  def sensor_positions(y:) = sensors.map(&:location).select { |bx, by| y == by }.map(&:first).to_set
  def not_beacon_positions(y:) = (mapped_positions(y: y) + sensor_positions(y: y) - beacon_positions(y: y))
end

path = ARGV.shift
row = ARGV.shift.to_i
sensors = SensorSet.load(path)
puts sensors.not_beacon_positions(y: row).count
