text = File.read(ARGV.shift)
lines = text.split("\n")

def to_range(s) = s.split("-").map(&:to_i).then { |x, y| (x..y) }
def range_pair(s) = s.split(",").map { |x| to_range(x) }
pairs = lines.map { |ln| range_pair(ln) }

def contains?(a, b) = a.include?(b.first) && a.include?(b.last)
def either_contains?(a, b) = contains?(a, b) || contains?(b, a)

enclosing_pairs = pairs.select { |a, b| either_contains?(a, b) }
puts enclosing_pairs.count
