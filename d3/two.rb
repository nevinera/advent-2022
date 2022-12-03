path = ARGV.shift
text = File.read(path)
lines = text.split("\n").map(&:strip)

require "set"
rucksacks = lines.map(&:chars).map(&:to_set)
groups = rucksacks.each_slice(3).to_a
intersections = groups.map {|g| g.reduce(&:intersection) }
badges = intersections.map { |s| s.to_a.first }

items = ("a" .. "z").to_a + ("A" .. "Z").to_a
priorities = items.each_with_index.map { |i, n| [i, n + 1] }.to_h

puts badges.map { |i| priorities[i] }.sum
