path = ARGV.shift
content = File.read(path)
lines = content.split("\n")

def all_different(signal) = signal.last(14).uniq.length == 14

def marker(s)
  signal = []
  s.chars.each_with_index do |char, n|
    signal << char
    if all_different(signal)
      return n + 1
    end
  end
  nil
end

lines.each do |line|
  puts marker(line)
end
