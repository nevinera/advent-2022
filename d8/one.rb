text = File.read(ARGV.shift)
@trees = text.split("\n").map { |line| line.chars.map(&:to_i) }
@height = @trees.length
@width = @trees.first.length

def h(c, r) = @trees[c][r]

def visible?(c, r)
  return true if (c == 0) || (r == 0) || (c == @width - 1) || (r == @height - 1)
  return true if (0..r-1).all?        { |x| h(c, x) < h(c, r) }
  return true if (r+1...@height).all? { |x| h(c, x) < h(c, r) }
  return true if (0..c-1).all?        { |x| h(x, r) < h(c, r) }
  return true if (c+1...@width).all?  { |x| h(x, r) < h(c, r) }
  false
end

total = 0
(0...@width).each do |c|
  (0...@height).each do |r|
    total += 1 if visible?(c, r)
  end
end
puts total
