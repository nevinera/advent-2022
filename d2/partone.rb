require "set"

#       PAPER   ROCK  SCISSORS
#  THEM:   B     A       C
#    US:   Y     X       Z

TREE = {
  "A" => {
    "X" => :tie,
    "Y" => :win,
    "Z" => :loss
  },
  "B" => {
    "X" => :loss,
    "Y" => :tie,
    "Z" => :win
  },
  "C" => {
    "X" => :win,
    "Y" => :loss,
    "Z" => :tie
  }
}
def outcome(them, me) = TREE.fetch(them).fetch(me)

PLAY_SCORES = {"X" => 1, "Y" => 2, "Z" => 3}
OUTCOME_SCORES = {win: 6, tie: 3, loss: 0}
def score(outcome, s) = PLAY_SCORES.fetch(s) + OUTCOME_SCORES.fetch(outcome)

guide_path = ARGV.shift
guide_text = File.read(guide_path)
guide = guide_text.strip.split("\n").map do |line|
  line.strip.split(/\s+/)
end

total_score = guide
  .map { |them, me| score(outcome(them, me), me) }
  .sum

puts total_score
