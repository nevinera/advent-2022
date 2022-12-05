text = File.read(ARGV.shift)
diagram, moves = text.split("\n\n")

diagram_lines = diagram.split("\n")
labels = diagram_lines.pop
colcount = labels.split(" ").last.to_i
warn "Column Count: #{colcount}"

rows = diagram_lines.map do |line|
  row = line.chars.each_slice(4).map { |s| s[1] }
end
warn "\nrows:"
rows.each { |r| warn(r.join) }

cols = (1..colcount).map { [] }
rows.reverse_each do |row|
  row.each_with_index do |x, n|
    cols[n] << x unless x == " "
  end
end
warn "\ncols:"
cols.each { |c| warn (c.join) }

instructions = moves.split("\n")
  .map { |line| line.scan(/\d+/).map(&:to_i) }
  .map { |q, s, d| [q, s - 1, d - 1] }           # turn stack-numbers into offsets

instructions.each do |quantity, source, destination|
  warn "\nmoving #{quantity} from cols[#{source}] -> cols[#{destination}]"
  quantity.times do
    item = cols[source].pop
    raise "popped nil" if item.nil?
    cols[destination] << item
  end
end

warn "\nafterward:"
cols.each { |c| warn (c.join) }

warn "\nanswer:"
warn cols.map(&:last).compact.join
