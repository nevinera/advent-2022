require "set"
require "pry"

text = File.read(ARGV.shift)
lines = text.split("\n")

@visited = Set.new
@knots = 10.times.map { [0, 0] }
@visited << @knots.last.dup

MOVES = {
  "R" => ->(x, y) { [x + 1, y] },
  "L" => ->(x, y) { [x - 1, y] },
  "U" => ->(x, y) { [x, y + 1] },
  "D" => ->(x, y) { [x, y - 1] }
}

def update_head(dirname)
  shifter = MOVES.fetch(dirname)
  @knots[0] = shifter.call(*@knots[0])
end

def knot_moves?(n)
  a = @knots[n - 1]
  b = @knots[n]
  dx = (a.first - b.first)
  dy = (a.last - b.last)
  nearby = (-1..1).include?(dx) && (-1..1).include?(dy)
  !nearby
end

def update_x(n)
  a = @knots[n - 1]
  b = @knots[n]
  if a.first - b.first > 0
    b[0] += 1
  elsif b.first - a.first > 0
    b[0] -= 1
  end
end

def update_y(n)
  a = @knots[n - 1]
  b = @knots[n]
  if a.last - b.last > 0
    b[1] += 1
  elsif b.last - a.last > 0
    b[1] -= 1
  end
end

def perform_move(dirname)
  update_head(dirname)
  (1..9).each do |n|
    if knot_moves?(n)
      update_x(n)
      update_y(n)
    end
  end
  @visited << @knots[9].dup
end

lines.each do |line|
  direction, distance = line.split(" ").then { |a, b| [a, b.to_i] }
  distance.times { perform_move(direction) }
end

puts @visited.count
