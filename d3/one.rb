path = ARGV.shift
text = File.read(path)
lines = text.split("\n").map(&:strip)

require "set"
line_chars = lines.map(&:chars)
sacks = line_chars.map do |lc|
  sack_size = lc.length / 2
  lc.each_slice(sack_size).map(&:to_set)
end
intersections = sacks.map { |a, b| a & b }
duplicates = intersections.map(&:to_a).map(&:first)
puts "duplicates: " + duplicates.join(", ")

items = ("a" .. "z").to_a + ("A" .. "Z").to_a
priorities = items.each_with_index.map { |i, n| [i, n + 1] }.to_h

puts duplicates.map { |i| priorities[i] }.sum
