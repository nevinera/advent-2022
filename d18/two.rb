require "set"
require "pry"

points = File.read(ARGV.shift).lines.map(&:strip).map { |ps| ps.split(",").map(&:to_i) }
point_set = points.to_set

ADJ = [
  [0, 0, -1],
  [0, 0, 1],
  [0, -1, 0],
  [0, 1, 0],
  [-1, 0, 0],
  [1, 0, 0]
]

def vadd(a, b) = a.zip(b).map(&:sum)
def sides_count(p, pset) = ADJ.reject { |d| pset.include?(vadd(p, d)) }.count
sides_per_point = points.map { |p| sides_count(p, point_set) }
warn "total_sides: #{sides_per_point.sum}"

# scoot the bounds _out_ one space, so there's empty space surrounding the object
# (so all exterior air sections are connected to each other for the flood-fill
@xmin = points.map { |p| p[0] }.min - 1
@xmax = points.map { |p| p[0] }.max + 1
@ymin = points.map { |p| p[1] }.min - 1
@ymax = points.map { |p| p[1] }.max + 1
@zmin = points.map { |p| p[2] }.min - 1
@zmax = points.map { |p| p[2] }.max + 1
warn "bounds: x=(#{@xmin}:#{@xmax}), y=(#{@ymin}:#{@ymax}), z=(#{@zmin}:#{@zmax})"

def in_bounds?(p)
  (@xmin..@xmax).include?(p[0]) &&
    (@ymin..@ymax).include?(p[1]) &&
    (@zmin..@zmax).include?(p[2])
end

@exterior = Set.new
@exterior << [@xmin, @ymin, @zmin]
loop do
  added = Set.new
  @exterior.map do |xp|
    ADJ.each do |delta|
      potential = vadd(xp, delta)
      if in_bounds?(potential) && !point_set.include?(potential)
        added << potential
      end
    end
  end
  break if (added - @exterior).empty?

  @exterior += added
end

# "air" that is not part of the exterior can just be counted as part of the droplet
enclosed_points = Set.new
(@xmin..@xmax).each do |x|
  (@ymin..@ymax).each do |y|
    (@zmin..@zmax).each do |z|
      enclosed_points << [x, y, z]
    end
  end
end

interior_air = enclosed_points - @exterior - point_set
warn "interior air: #{interior_air.size}"

# now rerun part 1, but including 'interior air' as part of the droplet
points2 = points + interior_air.to_a
point_set2 = points2.to_set
sides_per_point2 = points2.map { |p| sides_count(p, point_set2) }
warn "total exterior sides: #{sides_per_point2.sum}"

