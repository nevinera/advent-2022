input_path = ARGV.shift
content = File.read input_path

elves = content.strip.split("\n\n")
counts = elves.map do |elf_text|
  values = elf_text.strip.split("\n").map(&:strip).map(&:to_i)
  total = values.compact.sum
end

last_three = counts.sort.last(3)
puts last_three.sum
