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

@heights = []
@height_deltas = []

10000.times do |rock_number|
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
      old_board_max = @board_max
      @board_max = (rock.map(&:last) + [@board_max]).max
      @height_deltas << @board_max - old_board_max
      @heights << @board_max
      @stopped_rocks_count += 1
      @rocks << rock
      break
    else
      rock = next_position
    end
  end
end

puts "Board height: #{@board_max + 1}"


# There will be a cycle eventually, where the same jet and shape happen in the same
# sequence, and land on the same relative place.
# Turn the change-in-height of the board after each rock falls into a string, by
# mapping height-deltas to letters.
charmap = ["a", "b", "c", "d", "e", "f"]
deltas = @height_deltas.map { |d| charmap[d] }.join

# Find the first point at which it starts to repeat
def starts_repeating_at(str, chunk = 1000)
  (0..1000).each do |n|
    s = str.slice(n, chunk)
    s_offset = str.index(s, n + 1)
    return n if s_offset
  end

  nil
end

def repetition_period(str, start, chunk = 1000)
  slice = str.slice(start, chunk)
  next_at = str.index(slice, start + 1)
  after_that = str.index(slice, next_at + 1)

  fail unless next_at - start == after_that - next_at
  next_at - start
end

@start = starts_repeating_at(deltas)
@period = repetition_period(deltas, @start)
@periodic_sum = @height_deltas.slice(@start, @period).sum


# for sample, start = 15 and period = 35, so periodic_total is 53
# for _input_, start = 94 and period = 1735

target = 1_000_000_000_000
periods_to_drop = (target / @period) - 1
skipped_rocks_count = periods_to_drop * @period
height_before_timeskip = @heights[target - skipped_rocks_count]
height_after_timeskip = height_before_timeskip + (periods_to_drop * @periodic_sum)

warn "height: #{height_after_timeskip}"
binding.pry
