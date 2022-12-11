require "pry"

text = File.read(ARGV.shift)
lines = text.split("\n")

@x = 1
@values = []

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

@values << @x


n = 0
6.times do |row|
  k = 0
  40.times do |col|
    x = @values[n]

    if (-1..1).include?(k - x)
      $stdout.write("#")
    else
      $stdout.write(".")
    end

    k += 1
    n += 1
  end
  $stdout.write("\n")
end

