require "pry"
require "memery"

# lists are [ore, clay, obsidian, geodes], both of robots and materials

class Robot
  def initialize(cost, product)
    @cost, @product = cost, product
  end
  attr_reader :cost, :product
end

class State
  attr_reader :time, :robots, :materials

  def initialize(time, robots, materials)
    @time, @robots, @materials = time, robots, materials
  end

  def build_robot(n, cost)
    robots[n] += 1
    (0..3).each { |m| materials[m] -= cost[m] }
  end

  def wait_until(t) = state_after(t - time)

  def state_after(dt)
    new_materials = materials.each_with_index.map do |amount, material|
      amount + (robots[material] * dt)
    end
    State.new(time + dt, robots.dup, new_materials)
  end

  def time_until(cost)
    (0..3).map do |material|
      if cost[material] <= 0
        0
      elsif robots[material] <= 0
        Float::INFINITY
      else
        remaining = cost[material] - materials[material]
        (remaining / robots[material].to_f).ceil
      end
    end.max
  end
end

class Blueprint
  include Memery

  def self.from_line(max_time, line) = new(max_time, line.scan(/\d+/).map(&:to_i))

  attr_reader :max_time

  def initialize(max_time, values)
    @max_time, @values = max_time, values
  end

  memoize def number = @values.first
  memoize def quality_level = number * max_geodes_after(max_time)

  memoize def possible_robots
    [
      Robot.new(@values.slice(1, 1) + [0, 0, 0], 0),
      Robot.new(@values.slice(2, 1) + [0, 0, 0], 1),
      Robot.new(@values.slice(3, 2) + [0, 0], 2),
      Robot.new([0] + @values.slice(5, 2) + [0], 3)
    ]
  end

  memoize def possible_outcomes(step)
    return [State.new(0, [1, 0, 0, 0], [0, 0, 0, 0])] if step == 0

    prior_outcomes = possible_outcomes(step - 1)
    next_outcomes = prior_outcomes.map do |state|
      possible_robots.map do |r|
        dt = state.time_until(r.cost)
        if state.time + dt >= max_time
          # won't be done in time to matter
          nil
        else
          state.state_after(dt).tap { |s| s.build_robot(r.product, r.cost) }
        end
      end
    end.flatten.compact

    #halting_outcomes = next_outcomes.map { |ns| ns.wait_until(max_time) }

    warn " == Step #{step}: #{next_outcomes.length}"
    binding.pry
    next_outcomes
  end

  memoize def all_states = (0..24).map { |n| possible_outcomes(n) }.flatten
  memoize def terminals = all_states.map { |s| s.wait_until(max_time) }
  memoize def max_final_geodes = terminals.map { |state| state.materials.last }.max
end

lines = File.read(ARGV.shift).split("\n").map(&:strip)
time = ARGV.shift&.to_i || 24
blueprints = lines.map { |line| Blueprint.from_line(time, line) }
quality_sum = blueprints.map do |r|
  warn " ======== Blueprint #{r.number}"
  r.max_final_geodes
end.sum
warn "Quality sum: #{quality_sum}"

