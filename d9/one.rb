require "set"
require "pry"

text = File.read(ARGV.shift)
lines = text.split("\n")

@visited = Set.new
@head = [0, 0]
@tail = [0, 0]
@visited << @tail.dup

MOVES = {
  "R" => ->(x, y) { [x + 1, y] },
  "L" => ->(x, y) { [x - 1, y] },
  "U" => ->(x, y) { [x, y + 1] },
  "D" => ->(x, y) { [x, y - 1] }
}

def update_head(dirname)
  shifter = MOVES.fetch(dirname)
  @head = shifter.call(*@head)
end

def tail_moves?
  dx = (@head.first - @tail.first)
  dy = (@head.last - @tail.last)
  nearby = (-1..1).include?(dx) && (-1..1).include?(dy)
  !nearby
end

def update_tail_x
  if @head.first - @tail.first > 0
    @tail[0] += 1
  elsif @tail.first - @head.first > 0
    @tail[0] -= 1
  end
end

def update_tail_y
  if @head.last - @tail.last > 0
    @tail[1] += 1
  elsif @tail.last - @head.last > 0
    @tail[1] -= 1
  end
end

def perform_move(dirname)
  update_head(dirname)
  if tail_moves?
    update_tail_x
    update_tail_y
  end
  warn "H(#{@head.map(&:to_s).join(",")}), T(#{@tail.map(&:to_s).join(",")})"
  @visited << @tail.dup
end

lines.each do |line|
  direction, distance = line.split(" ").then { |a, b| [a, b.to_i] }
  warn "MOVE #{direction} #{distance}"
  distance.times { perform_move(direction) }
end

puts @visited.count
