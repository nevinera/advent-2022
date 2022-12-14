require "json"
require "pry"

text = File.read(ARGV.shift)
lines = text.split("\n").select { |line| line =~ /\S/ }
lists = lines.map { |line| JSON.parse(line) }

lists << [[2]]
lists << [[6]]

# x <=> y returns 0 if they are equal, 1 if y > x, and -1 if y < x

def cmp_entries(left, right, indent = "")
  warn "#{indent} cmp_entries:"
  warn "#{indent}   #{left.to_json}"
  warn "#{indent}   #{right.to_json}"
  return left <=> right if left.is_a?(Integer) && right.is_a?(Integer)

  # if a list runs out, it'll have a nil after the end. nil comes before all
  # we should never get _two_ nils here, since the zip would have stopped
  return -1 if left.nil?
  return 1 if right.nil?

  # if either is a list, do a list-comparison
  left = [left] if left.is_a?(Integer)
  right = [right] if right.is_a?(Integer)
  cmp_lists(left, right, indent + " ")
end

def cmp_lists(left, right, indent = "")
  warn "#{indent} cmp_lists:"
  warn "#{indent}   #{left.to_json}"
  warn "#{indent}   #{right.to_json}"
  left.zip(right).each do |a, b|
    x = cmp_entries(a, b, indent + " ")
    return x if x != 0
  end

  if left.length < right.length
    -1
  else
    0
  end
end

sorted_lists = lists.sort { |a, b| cmp_entries(a, b) }

puts "\n\nSORTED:"
sorted_lists.each_with_index do |list, n|
  puts list.to_json
  @x = n + 1 if list == [[2]]
  @y = n + 1 if list == [[6]]
end

puts "dividers: #{@x} x #{@y} = #{@x * @y}"
