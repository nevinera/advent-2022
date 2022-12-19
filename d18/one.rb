require "set"

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
