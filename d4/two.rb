text = File.read(ARGV.shift)
lines = text.split("\n")

def to_range(s) = s.split("-").map(&:to_i).then { |x, y| (x..y) }
def range_pair(s) = s.split(",").map { |x| to_range(x) }
pairs = lines.map { |ln| range_pair(ln) }

def includes?(a, b) = a.include?(b.first) || a.include?(b.last)
def overlap?(a, b) = includes?(a, b) || includes?(b, a)

overlapping_pairs = pairs.select { |a, b| overlap?(a, b) }
puts overlapping_pairs.count
