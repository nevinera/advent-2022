text = File.read(ARGV.shift)
lines = text.split("\n")

@x = 1
@values = [1]

lines.each do |line|
  if line == "noop"
    @values << @x
  elsif line.start_with?("addx")
    v = line.split(" ").last.to_i
    @values << @x
    @values << @x
    @x += v
  else
    fail("unexpected instruction on line #{line}")
  end
end

def sig(n) = @values[n] * n

puts sig(20) + sig(60) + sig(100) + sig(140) + sig(180) + sig(220)
