require "memery"
require "pry"

lines = File.read(ARGV.shift).split("\n")

@heights = ('a' .. 'z').each_with_index.map { |c, n| [c, n] }.to_h

@distances = {}
@map = {}

lines.each_with_index do |line, row|
  line.chars.each_with_index do |c, col|
    if c == "S"
      @map[[row, col]] = 0
    elsif c == "E"
      @map[[row, col]] = 25
      @distances[[row, col]] = 0
    else
      @map[[row, col]] = @heights[c]
    end
  end
end

def height(r, c)
  @map.fetch([r, c])
end

def adjacencies(r, c)
  fail unless height(r, c)

  potentials = [
    [r-1, c],
    [r+1, c],
    [r, c-1],
    [r, c+1]
  ]

  potentials.select do |r2, c2|
    @map.key?([r2, c2])
  end
end

def reachables(r, c)
  h = height(r, c)
  adjacencies(r, c)
    .reject { |r2, c2| @distances.key?([r2, c2]) } # already reached
    .select { |r2, c2| height(r2, c2) >= h - 1 }
end

loop do
  expanded = false

  step = {}
  @distances.each_pair do |coords, d|
    reaches = reachables(*coords)
    expanded = true if reaches.any?
    reaches.each do |r, c|
      step[[r, c]] = d + 1
    end
  end

  step.each do |coords, d|
    if height(*coords) == 0
      puts "found one at [#{coords.first}, #{coords.last}]: #{d}"
      exit(0)
    end
  end

  @distances.merge!(step)

  break if expanded == false
end

binding.pry
puts @distances.fetch(@finish)
