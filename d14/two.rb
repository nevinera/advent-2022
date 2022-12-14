require "set"
require "pry"

def absrange(a, b) = b > a ? (a..b) : (b..a)

def read_rocks(path)
  lines = File.read(path).split("\n").map(&:strip)

  rocks =  Set.new
  lines.each do |line|
    points = line.split("->").map { |p| p.strip.split(",").map(&:to_i) }
    points.each_cons(2) do |a, b|

      absrange(a.first, b.first).each do |x|
        absrange(a.last, b.last).each do |y|
          rocks << [x, y]
        end
      end
    end
  end

  rocks
end

def add_floor(rocks, floor_level)
  (490-floor_level .. 510+floor_level).each { |x| rocks << [x, floor_level] }
end

def find_bottom(rocks) = rocks.map(&:last).max

def print_state(rocks, sand, bottom)
  x_list = rocks.map(&:first).sort
  min_x, max_x = x_list.first, x_list.last

  $stdout.write("\n")
  (0..bottom).each do |y|
    (min_x..max_x).each do |x|
      if rocks.include?([x, y])
        $stdout.write("#")
      elsif sand.include?([x, y])
        $stdout.write("o")
      else
        $stdout.write(".")
      end
    end
    $stdout.write("\n")
  end
end

def empty?(rocks, sand, location) = !rocks.include?(location) && !sand.include?(location)

def sand_next(rocks, sand, location)
  x, y = location
  if empty?(rocks, sand, [x, y + 1])
    [x, y + 1]
  elsif empty?(rocks, sand, [x - 1, y + 1])
    [x - 1, y + 1]
  elsif empty?(rocks, sand, [x + 1, y + 1])
    [x + 1, y + 1]
  else
    [x, y]
  end
end

# nil if off the bottom,
# false if rest on start_location
# true if rest elsewhere
def add_sand(rocks, sand, start_location, bottom)
  x, y = start_location

  loop do
    nx, ny = sand_next(rocks, sand, [x, y])
    raise "fell" if ny > bottom

    if [x, y] == [nx, ny]
      sand << [x, y]

      if [x, y] == start_location
        return false
      else
        return true
      end
    end


    x, y = nx, ny
  end
end

rocks = read_rocks(ARGV.shift)
bottom = find_bottom(rocks)
add_floor(rocks, bottom + 2)
bottom = bottom + 2

sand = Set.new
print_state(rocks, sand, bottom)

while add_sand(rocks, sand, [500, 0], bottom)
  true
end

print_state(rocks, sand, bottom)
puts sand.size
