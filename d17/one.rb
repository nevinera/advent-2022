require "pry"
require "set"
require "json"

@jets = File.read(ARGV.shift).strip.chars

JET_DELTAS = {
  ">" => [1, 0],
  "<" => [-1, 0]
}

DOWN = [0, -1]

# coordinates are [X, Y], with positive being up and to the right.
# The zero of the board is at the bottom left, with [0, 0] being inside the board
# The zero of each _piece_ is at their bottom left, and may not be inside the piece.

SHAPES = [
  [[0, 0], [1, 0], [2, 0], [3, 0]],           # horizontal line
  [[1, 0], [0, 1], [1, 1], [1, 2], [2, 1]],   # plus sign
  [[0, 0], [1, 0], [2, 0], [2, 1], [2, 2]],   # L shape
  [[0, 0], [0, 1], [0, 2], [0, 3]],           # vertical line
  [[0, 0], [0, 1], [1, 0], [1, 1]]
]

@board = Set.new
@board_max = -1

def starting_point = [2, @board_max + 4]

def shape_at(shape, p) = shape.map { |sp| [sp.first + p.first, sp.last + p.last] }

def occluded?(rock)
  return true if rock.any? { |p| p.first < 0 || p.first > 6 }
  return true if rock.any? { |p| @board.include?(p) }
  return true if rock.any? { |p| p.last < 0 }
  false
end

def shifted(rock, delta) = rock.map { |p| [p.first + delta.first, p.last + delta.last] }

@stopped_rocks_count = 0
@jets_count = 0
@rocks = []

2022.times do |rock_number|
  warn "rock #{rock_number} is falling" if rock_number % 50 == 0

  shape_number = rock_number % 5
  rock_shape = SHAPES[shape_number].dup
  rock = shape_at(rock_shape, starting_point)

  loop do
    # first jet pushes sideways
    jet_number = @jets_count % @jets.length
    jet_delta = JET_DELTAS.fetch(@jets[jet_number])
    @jets_count += 1

    next_position = shifted(rock, jet_delta)
    if !occluded?(next_position)
      rock = next_position
    end

    # then gravity pushes downwards
    next_position = shifted(rock, DOWN)
    if occluded?(next_position)
      rock.each { |p| @board << p }
      @board_max = (rock.map(&:last) + [@board_max]).max
      @stopped_rocks_count += 1
      @rocks << rock
      break
    else
      rock = next_position
    end
  end
end

puts "Board height: #{@board_max + 1}"
