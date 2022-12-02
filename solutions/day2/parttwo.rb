require "set"

#       PAPER   ROCK  SCISSORS
#  THEM:   B     A       C
#    US:   Y     X       Z

SCORE = {
  "A" => { # they choose rock
    "X" => 0 + 3, # lose (scissors)
    "Y" => 3 + 1, # tie (rock)
    "Z" => 6 + 2  # win (paper)
  },
  "B" => { # they choose paper
    "X" => 0 + 1, # lose (rock)
    "Y" => 3 + 2, # tie (paper)
    "Z" => 6 + 3  # win (scissors)
  },
  "C" => { # they choose scissors
    "X" => 0 + 2, # lose (paper)
    "Y" => 3 + 3, # tie (scissors)
    "Z" => 6 + 1  # win (rock)
  }
}

def score(them, me) = SCORE.fetch(them).fetch(me)

guide_path = ARGV.shift
guide_text = File.read(guide_path)
guide = guide_text.strip.split("\n").map do |line|
  line.strip.split(/\s+/)
end

scores = guide.map { |them, me| score(them, me) }
puts scores.sum
