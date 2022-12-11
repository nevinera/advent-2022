require "pry"
text = File.read(ARGV.shift)

chunks = text.split("\n\n")
monkeys = chunks.map do |chunk|
  lines = chunk.split("\n")
  name = lines.first
  items = lines[1].split(":").last.split(",").map(&:strip).map(&:to_i)
  op, val_s= lines[2].split(" ").last(2)
  operation = ->(x) { x.send(op, val_s == "old" ? x : val_s.to_i) }
  factor = lines[3].split(" ").last.to_i
  if_true = lines[4].split(" ").last.to_i
  if_false = lines[5].split(" ").last.to_i
  choice = ->(x) { x % factor == 0 ? if_true : if_false }

  {name: name, items: items, operation: operation, choice: choice}
end

nodamage = ->(x) { (x / 3).to_i }

inspected = monkeys.map { 0 }

20.times do |n|
  monkeys.each_with_index do |monkey, n|
    warn "monkey #{n}"
    while monkey[:items].any?
      orig = item = monkey[:items].shift
      inspected[n] += 1
      item = monkey[:operation].call(item)
      item = nodamage.call(item)
      next_monkey = monkey[:choice].call(item)
      warn "  item: #{orig}->#{item}, throw(#{next_monkey})"
      monkeys[next_monkey][:items] << item
    end
  end
end

puts inspected

puts inspected.sort.last(2).reduce(&:*)
