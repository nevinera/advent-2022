require "json"

text = File.read(ARGV.shift)
lines = text.split("\n").select { |line| line =~ /\S/ }
lists = lines.map { |line| JSON.parse(line) }
pairs = lists.each_slice(2).to_a

# x <=> y returns 0 if they are equal, 1 if x > y, and -1 if x < y

def cmp_entries(left, right, indent = "")
  warn "#{indent} cmp_entries:"
  warn "#{indent}   #{left.to_json}"
  warn "#{indent}   #{right.to_json}"
  return right <=> left if left.is_a?(Integer) && right.is_a?(Integer)

  # if a list runs out, it'll have a nil after the end. nil comes before all
  # we should never get _two_ nils here, since the zip would have stopped
  return 1 if left.nil?
  return -1 if right.nil?

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
    1
  else
    0
  end
end

corrects = []
n = 1
pairs.each do |left, right|
  warn "\n\n-------- comparing #{left.to_json} <=> #{right.to_json} --------"

  r = cmp_entries(left, right)
  warn "  #{r}"
  if r < 0
    warn "  wrong"
  else
    warn "  right"
    corrects << n
  end

  n += 1
end

puts "sum: #{corrects.sum}"
