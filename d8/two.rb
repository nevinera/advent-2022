require "pry"
text = File.read(ARGV.shift)
@trees = text.split("\n").map { |line| line.chars.map(&:to_i) }
@height = @trees.length
@width = @trees.first.length

def h(c, r) = @trees[r][c]

def take_until(enum, &block)
  stopped = false
  result = []
  enum.map do |value|
    result << value
    break if block.call(value)
  end
  result
end

def score(c, r)
  return 0 if c == 0 || r == 0 || c == @width-1 || r == @height-1

  left   = take_until((0..c-1).to_a.reverse) { |n| h(n, r) >= h(c, r) }
  right  = take_until((c+1..@width-1))       { |n| h(n, r) >= h(c, r) } 
  top    = take_until((0..r-1).to_a.reverse) { |n| h(c, n) >= h(c, r) }
  bottom = take_until((r+1..@height-1))      { |n| h(c, n) >= h(c, r) }

  counts = [left, right, top, bottom].map(&:length).reduce(&:*)
end

scores = []
(0...@width).each do |c|
  (0...@height).each do |r|
    scores << score(c, r)
  end
end
puts scores.max
