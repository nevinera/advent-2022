path = ARGV.shift
text = File.read(path)
lines = text.split("\n")

class Item
  def initialize(name, parent, size)
    @name, @parent, @size = name, parent, size
  end

  attr_reader :name, :parent, :size

  def display(indent="")
    puts indent + "#{name}   (#{size})"
  end
end

class Dir
  def initialize(name, parent)
    @name, @parent = name, parent
    @files, @dirs = [], []
  end

  attr_reader :name, :parent, :files, :dirs

  def add_file(size, name)
    files << Item.new(name, self, size)
  end

  def find_dir(name)
    dirs.detect{ |d| d.name == name }.tap do |d|
      fail "unknown dir" unless d
    end
  end

  attr_accessor :total_size

  def files_size
    @_files_size ||= files.map(&:size).sum
  end

  def dirs_size
    @_dirs_size ||= dirs.map(&:total_size).sum
  end

  def total_size
    @_total_size ||= (files_size + dirs_size)
  end

  def display(indent="")
    puts indent + name + "/"
    files.each { |f| f.display(indent + "  ") }
    dirs.each { |d| d.display(indent + "  ") }
  end
end

@root = Dir.new("", nil)
@dirs = [@root]
@cwd = @root

lines.each do |line|
  puts "processing: #{line}"
  parts = line.split(/\s+/)

  if line == "$ cd /"
    @cwd = @root
  elsif line == "$ cd .."
    @cwd = @cwd.parent
  elsif line.start_with?("$ cd")
    @cwd = @cwd.find_dir(parts.last)
  elsif line.start_with?("$ ls")
    # no-op - we'll encounter dir/file lines and process them,
    # but nothing cares (yet) to confirm that we actually asked
  elsif line.start_with?("dir ")
    dir = Dir.new(parts.last, @cwd)
    @cwd.dirs << dir
    @dirs << dir
  elsif line =~ /^\d+/
    @cwd.add_file(parts.first.to_i, parts.last)
  else
    fail "bad line"
  end

  puts "----------------"
  puts "  CWD: #{@cwd.name}"
  @root.display
  puts "\n\n"
end

puts "\n\n"
@root.display
puts "\n\n"

puts "-------------------"
puts "Dir Sizes:"
@dirs.sort_by(&:total_size).each do |d|
  puts " - #{d.name}: #{d.total_size}"
end
puts "\n\n"

total_space = 70000000
current_space = @root.total_size
free_space = total_space - current_space
needed_space = 30000000 - free_space
fail "already fine" if needed_space <= 0

smallest = @dirs.sort_by(&:total_size).detect { |d| d.total_size >= needed_space }
puts "Dir #{smallest.name}: #{smallest.total_size}"
